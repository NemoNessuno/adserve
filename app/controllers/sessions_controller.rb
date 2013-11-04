class SessionsController < ApplicationController
  def new
  end

  def create
    authinfo = params["/sessions"]
    user = User.authenticate(authinfo[:email], authinfo[:password])
    if user
      session[:user_id] = user.id     
      
      case user
      when Advertiser
        redirect_to advertisers_home_url, :notice => "You successfully logged in!"
      when Publisher
        redirect_to publishers_home_url, :notice => "You successfully logged in!"
      when Admin
        redirect_to admins_home_url, :notice => "You successfully logged in!"
      #Just a safe fall back. This should never happen!  
      else
        logger.error("The email: #{user.email} got a wrong user type: #{user.class.name}!")
        session[:user_id] = nil
        render "new"
      end      
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
