class WebsitesController < ApplicationController
  layout :publisher_layout
  
  include Query

  def create
    @user ||= Publisher.retrieve(session[:user_id])
    @website = Website.new(params[:website])
    @website.zone_strings.split(',').each do |zs| 
      zone = Zone.new(:size => zs)
      zone.website = @website
      @website.zone << zone
    end

    @user.website << @website
    @website.publisher = @user
    tryToSaveWebsite
  end

  def update
    @website = Website.new(params[:website])

  end

  def destroy

  end

  def find
    session[:websites] = getWebsites

    redirect_to advertisers_find_websites_path
  end

  def tryToSaveWebsite
    if @user.save
      redirect_to publishers_websites_path, :notice => "You successfully added a Website"
    else
      session[:website] = params[:website]
      session[:errors] = @website.errors.messages
      redirect_to publishers_websites_path
    end
  end

end
