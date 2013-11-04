class PublishersController < ApplicationController

  include Query

  def new
    @user = Publisher.new
    render :action => "/users/new", :layout => 'application'
  end

  def home
    @menuindex = 0
  end

  def websites
    @menuindex = 1
    
    @user = Publisher.retrieve(session[:user_id])
    @website = Website.new(session.delete(:website) || {})
    errors = session.delete(:errors)
    unless errors.nil?
      errors.each do |k,v|
        v.each {|value| @website.errors.add(k,value)}
      end
    end
  end
  
  def show_campaign
    @menuindex = 2
    @user ||= Publisher.retrieve(session[:user_id])
    @campaign = Campaign.retrieve(params[:id])
  end

  def find_campaigns
    @menuindex = 2

    @campaign = Campaign.new
    @campaigns = session[:campaigns] || []
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
    @menuindex = 6
  end

  def create
    @user = Publisher.new(params[:publisher])
    tryToCreateUser
  end
  
  def apply
  campaign_hash = session.delete(:campaigns).first
  @campaign = Campaign.retrieve(campaign_hash[:id])
  
  message = Message.new
  message.sender = Publisher.retrieve(session[:user_id])

  message.recipient = @campaign.advertiser
  
  intevent = Intevent.applicationEvent
  intevent.message = message
  
  intevent.ids << @campaign.id
  
  zone_ids = {}
  params.delete_if { |k,v| v != "1" || !k.to_s.start_with?("zone_") }.each_key do |key|
    zone_key = key[5..36]
    ad_key = key[41..72]
    if zone_ids[zone_key].nil?
      zone_ids[zone_key] = [ad_key]
    elsif
      zone_ids[zone_key] << ad_key
    end
  end

  intevent.ids << zone_ids
  message.content = " "
  message.intevent << intevent
  message.save!

  redirect_to publishers_home_path, :notice => "You applied for the campaign. It's owner will be notified and he will get in contact with you."
  end

  def update
    @user = Publisher.new(params[:publisher])
    begin
      #TODO UserUpdating!
      Publisher.retrieve(@user.id)
    rescue
      tryToCreateUser
    end
  end

  def tryToCreateUser
    if @user.save
      @user = Publisher.retrieve(@user.id)

      session[:user_id] = @user.id
      redirect_to publishers_home_path, :notice => "You successfully signed up " + @user.full_name
    else
      render :action => "/users/new", :layout => 'application'
    end
  end

end
