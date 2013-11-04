class CampaignsController < ApplicationController
  include Query
  
  layout :advertiser_layout
  def create
    @user ||= Advertiser.retrieve(session[:user_id])
    @campaign = Campaign.new(params[:campaign])
    
    @user.campaign << @campaign
    @campaign.advertiser = @user
  
    params.delete_if { |k,v| v != "1" || !k.to_s.start_with?("ad_") }.each_key do |key|
      @campaign.ad << Ad.retrieve(key.to_s.sub("ad_",""))
    end

    tryToSaveCampaign
  end
  
  def addZones
    #TODO: Implement
  end

  def find
    session[:campaigns] = getCampaigns

    redirect_to publishers_find_campaigns_path
  end

  def update
    @campaign = Campaign.new(params[:campaign])

  end

  def destroy

  end

  def tryToSaveCampaign
    if @user.save

      redirect_to advertisers_campaigns_path, :notice => "You successfully added a Campaign"
    else
      session[:campaign] = params[:campaign]
      session[:errors] ||= Hash.new 
      session[:errors][:campaign] = @campaign.errors.messages
      redirect_to advertisers_campaigns_path
    end
  end

end
