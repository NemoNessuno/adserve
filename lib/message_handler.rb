#TODO: Refactor HTMl Strings! Where to put them?
require 'yaml'
require 'couchbase'

module MessageHandler

  BLOCK = "block_"
  UNBLOCK = "unblock_"
  APPLICATION = "application_"
  ACCEPT_APPLICATION = "accept_application_"

  SUBJECT = "subject"
  CONTENT = "content"

  def getString(key)
    @strings ||= readDoc
    return @strings[key]
  end
  
  def contentReplacements(key)
    @replacements ||= {
      BLOCK       => Proc.new {|content,message| fill_in_name(content, message)},
      UNBLOCK     => Proc.new {|content,message| fill_in_name(content, message)},
      APPLICATION => Proc.new {|content,message| fill_in_zone_data fill_in_campaign_data (fill_in_name content, message)},
      ACCEPT_APPLICATION => Proc.new {|content,message| fill_in_campaign_data fill_in_name content, message}
    }
    @replacements[key]
  end
  
  def getFunction(message)
    get_event_type(message.intevent)
  end

  def getSubject(message)
    
    function = get_event_type(message.intevent)
    return fill_in_name(getString("fallback"),message)[0] if function.nil?

    sender = "#{message.sender.type}_"

    fill_in_name(getString("#{sender}#{function}subject"),message).first
  end
  
  def getContent(message)
    
    function = get_event_type(message.intevent)
    return message.content if function.nil?

    sender = "#{message.sender.type}_"
    content = getString("#{sender}#{function}content")
    
    contentReplacements(function).call(content, message)[0]
  end
  
  def get_event_type(intevents)
    return nil if intevents.length == 0

    case intevents[0].event_type
    when EventType::BLOCK
      BLOCK
    when EventType::UNBLOCK
      UNBLOCK
    when EventType::APPLICATION
      APPLICATION
    when EventType::ACCEPT_APPLICATION
      ACCEPT_APPLICATION
    else 
      nil
    end
  end

  def fill_in_name(string, message)
    return [string.sub("\{1\}", message.sender.full_name), message]
  end

  def fill_in_campaign_data(arg_array)
    content = arg_array.first
    message = arg_array.second
    
    if  message.recipient.is_a? Advertiser
      campaigns = message.recipient.campaign
    else
      campaigns = message.sender.campaign
    end

    campaign = campaigns.select{|c|
      message.intevent[0].ids.first == c.id
    }.first

    return [content.sub("\{2\}", "<br/><br/><b>name:</b> #{campaign.name}<br/><b>target url:</b> #{campaign.target_url}<br/><br/>").html_safe, message]
  end

  def fill_in_zone_data(arg_array)
    content = arg_array.first
    message = arg_array.second
    
    zone_hash = message.intevent[0].ids[1]

    websites = message.sender.website.select do |w|
      w.zone.any? {|z| zone_hash.keys.include? z.id}
    end
    
    replacement = ""

    websites.each do |w|
      offered_zones = w.zone.select {|z| zone_hash.keys.include? z.id }
      replacement += "<br/><br/><b>base url:</b> #{w.base_url}<br/><b>categories:</b> #{w.categories}<br/><b>zones</b> that are offered on this website:<br/><br/>"
      offered_zones.each do |zone|
        replacement += "<b>width:</b> #{zone.width} <b>height:</b> #{zone.height}<br/><br/><b>ads:</b><br/>"
        zone_hash[zone.id].each do |ad_id|
          replacement += "<b>content:</b> #{(message.recipient.ad.select {|ad| ad_id == ad.id}).first.content}<br/>"
        end
        replacement += "<br/>"
      end
    end

    return [content.sub("\{3\}", replacement).html_safe, message]
  end
    
  def readDoc()
    YAML.load_file("#{File.expand_path("../",__FILE__)}/assets/message_strings.yml")
  end

  private :readDoc, :getString 

end
