class AdminsController < ApplicationController
  include Query

  def home
    @menuindex = 0
  end

  def websites
    @menuindex = 1
  end

  def campaigns
    @menuindex = 2
  end

  def new
    @user = Admin.new
    render :action => "/users/new", :layout => 'application'
  end

  def create
    if (getAdmins.length == 0)
      @user = Admin.new(params[:admin])
      tryToCreateUser
    else
      redirect_to "/"
    end
  end

  def update
    @user = Admin.new(params[:admin])
    begin
      #TODO UserUpdating!
      Admin.retrieve(@user.id)
    rescue
      tryToCreateUser
    end
  end

  def tryToCreateUser
    if @user.save
      @user = Admin.retrieve(@user.id)

      session[:user_id] = @user.id
      redirect_to admins_home_path, :notice => "You successfully signed up " + @user.full_name
    else
      render :action => "/users/new", :layout => 'application'
    end
  end

end
