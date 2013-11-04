class AdsController < ApplicationController
  layout :advertiser_layout

  def create
    @user = Advertiser.retrieve(session[:user_id])
    params[:ad][:size] = "#{params[:ad][:width]}; #{params[:ad][:height]}"
    @ad = Ad.new(params[:ad])
    
    @user.ad << @ad
    @ad.advertiser = @user
    tryToSaveAd
  end

  def update
    @ad = Ad.new(params[:ad])

  end

  def destroy

  end

  def tryToSaveAd
    if @user.save

      redirect_to advertisers_campaigns_path, :notice => "You successfully added a Ad"
    else
      session[:ad] = params[:ad]
      session[:errors] ||= Hash.new
      session[:errors][:ad] = @ad.errors.messages
      session[:errors][:ad][:width] = session[:errors][:ad][:height] = ["width and height must be greater than 0"] unless session[:errors][:ad].delete(:size).nil?
      redirect_to advertisers_campaigns_path
    end
  end

end
