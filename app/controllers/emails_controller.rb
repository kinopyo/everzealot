class EmailsController < ApplicationController

  def new
    # if no image is selected
    redirect_to :controller => "home", :action => "index" and flash[:notice] = "please select the notebook and image first." if session[:image_urls].nil?

    @email = Email.new
    @from = cookies[:from] unless cookies[:from].nil?

  end

  def create
    @email = Email.new(params[:email])

    if @email.save
      #set cookie
      cookies[:from] = params[:email]["from_email"]

      # send mail
      UserMailer.send_image_mail(params[:email],session[:files]).deliver
      
      # clear session
      session[:files] = nil
      session[:image_urls] = nil

      flash[:notice] = 'OK! Your mail has been sent.'
      redirect_to :controller => "home", :action => "index"
    else
      render :action => "new"
    end
  end

end
