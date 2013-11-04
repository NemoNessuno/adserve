class AdvertisersController < ApplicationController
  include Query

  def new 
    @user = Advertiser.new
    render :action => "/users/new", :layout => 'application'
  end

  def home
    #todo: announce invalid campaigns and help do sth about it!
    @menuindex = 0
  end

  def create
    @user = Advertiser.new(params[:advertiser])
    tryToCreateUser
  end

  def update
    @user = Advertiser.new(params[:advertiser])
    begin
      #TODO UserUpdating!
      Advertiser.retrieve(@user.id)
    rescue
      tryToCreateUser
    end
  end

  def tryToCreateUser
    if @user.save
      @user = Advertiser.retrieve(@user.id)

      session[:user_id] = @user.id
      redirect_to advertisers_home_path, :notice => "You successfully signed up " + @user.full_name
    else
      render :action => "/users/new", :layout => 'application'
    end
  end
  
  def handle_message
    #For now we can only handle applications
    message = Message.retrieve(params[:message][:id])
    @user = Advertiser.retrieve(session[:user_id])
    
    Message.acceptApplication(message).save!
    
    message.intevent[0].ids.second.each do |zone_id, ad_ids|
      zone = Zone.retrieve(zone_id)
      ad_ids.each { |ad_id| zone.ad << Ad.retrieve(ad_id) }
      zone.save!
    end
    message.delete

    redirect_to advertisers_messages_path, :notice => "Application accepted."
  end

  def campaigns
    @menuindex = 1

    @user = Advertiser.retrieve(session[:user_id])
    @campaign = Campaign.new(session.delete(:campaign) || {})
    @ad = Ad.new(session.delete(:ad) || {})
    errors = session.delete(:errors)
    unless errors.nil?
      errors.each do |k,v|
        case k
        when :campaign
          v.each {|key, value| @campaign.errors.add(key,value.join())}
        when :ad
          v.each {|key, value| @ad.errors.add(key,value.join())}
        else
          # do nothing
        end
      end
    end
  end

  def find_websites
    @menuindex = 2
    @website = Website.new
    @websites = session.delete(:websites) || []
  end

  def billing
    @menuindex = 3
  end

  def analysis
    @menuindex = 4
  end

  def messages
    @menuindex = 5

    @messages = []
    getMessages(session[:user_id]).each do |m_hash|
      message = Message.retrieve(m_hash[:id])
      @messages << message
    end
  end

  def help
    @menuindex = 5
  end
end
