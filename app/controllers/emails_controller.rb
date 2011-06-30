class EmailsController < ApplicationController

  def new
    @email = Email.new
    
  end

  def create
    @email = Email.new(params[:email])

    respond_to do |format|
      if @email.save
        # send mail
        UserMailer.send_image_mail(params[:email],session[:files]).deliver
        session[:files] = nil
        session[:image_urls] = nil

          # render :text => "Email was successfully sent"
        format.html { redirect_to :controller => "home", :action => "index", notice: 'Email was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
