require 'yaml'
require 'couchbase'

module Query

  def default_bucket
    return Rails.env.test? ? "testadserve" : "adserve"
  end

  def idHash
    @idHash ||= {
      :id => Proc.new {|doc| doc.send 'id'}
    }
  end

  def basicHash 
    @basicHash ||= idHash.merge({
      :name => Proc.new {|doc| doc.send 'key'}
    })
  end

  def websiteHash
    @websiteHash ||= basicHash.merge({
      :categories => Proc.new {|doc| doc.send('value')[0]},
      :zones => Proc.new {|doc| doc.send('value')[1]}
    })
  end

  def campaignHash
    @campaignHash ||= basicHash.merge({
      :categories => Proc.new {|doc| doc.send('value')[0]},
      :expiration_date => Proc.new {|doc| doc.send('value')[1]},
      :cp_view => Proc.new {|doc| doc.send('value')[2]},
      :cp_click=> Proc.new {|doc| doc.send('value')[3]},
      :cp_conversion => Proc.new {|doc| doc.send('value')[4]}
    })
  end

  def messageHash
    @messageHash ||= idHash.merge({
      :sender => Proc.new {|doc| doc.send('key') },
      :recipient => Proc.new {|doc| doc.send('value')}
    })
  end

  #Filters messages by the id of the recipient
  def messagesFilter(id)
    @messagesFilters ||= Hash.new
    @messagesFilters[id] ||= {
      :recipient => Proc.new {|user_id| user_id == id }
    }
  end

  def getMessages(recipient_id, bucket = default_bucket)
    getResults(queryMessages(bucket), messageHash, messagesFilter(recipient_id))
  end

  def getCampaigns(filter = Hash.new)
    getResults(queryCampaigns, campaignHash, filter)
  end

  def getWebsites(filter = Hash.new)
    getResults(queryWebsites, websiteHash, filter)
  end

  def getAdmins(filter = Hash.new)
    getResults(queryAdmins, idHash, filter)
  end

  def getResults(hash, mask, filter)
    result = hash.map {|doc| Hash[ mask.map { |field, method| [field, method.call(doc)] }]}
    unless filter.empty?
      result.select! do |doc|
        doc.keys.all? { |key| (!filter.key?(key)) || filter[key].call(doc[key]) }
      end
    end
    return result
  end

  def queryMessages(bucket)
    query(bucket, 'messages')
  end

  def queryWebsites(bucket = default_bucket)
    query(bucket, 'websites')
  end

  def queryCampaigns(bucket = default_bucket)
    query(bucket, 'campaigns')
  end

  def queryAdmins(bucket = default_bucket)
    query(bucket, 'admins')
  end

  def query(bucket, category)
    @c ||= Couchbase.connect "http://localhost:8091/pools/default/buckets/#{bucket}"
    
    results = @c.design_docs[category]
    return results.send(category) unless results.nil?

    addDocument category
    
    @c.design_docs[category].send(category)
  end

  def addDocument(name)
    @c.save_design_doc(readDoc(name))
  end
  
  def readDoc(name)
      YAML.to_json(YAML.load_file("#{File.expand_path("../",__FILE__)}/assets/#{name}.yml")).gsub("\n","")
  end

  private :addDocument, :readDoc, :query, :queryCampaigns, :queryWebsites, :getResults,:basicHash, :websiteHash, :campaignHash

end 
