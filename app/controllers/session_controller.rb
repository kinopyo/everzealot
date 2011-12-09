class SessionController < ApplicationController
  def authorize
    callback_url = request.url.chomp("authorize").concat("callback")

    begin
      consumer = OAuth::Consumer.new(OAUTH_CONSUMER_KEY,
                                     OAUTH_CONSUMER_SECRET,
                                     {
                                       :site => EVERNOTE_SERVER,
                                       :request_token_path => "/oauth",
                                       :access_token_path => "/oauth",
                                       :authorize_path => "/OAuth.action?format=microclip"
                                     })
      session[:request_token] = consumer.get_request_token(:oauth_callback => callback_url)
      redirect_to session[:request_token].authorize_url
    rescue Exception => e
      @last_error = "Error obtaining temporary credentials. Please try later."
      p "Log::Error,  #{e.inspect}"
      render :error
    end
  end

  def callback
    if (params['oauth_verifier'].nil?)
      Rails.logger.debug { " owner did not authorize the temporary credentials" }
      @last_error = "Oops! You need to authorize this website first."
      render :error
    else
      oauth_verifier = params['oauth_verifier']
      session[:access_token] = session[:request_token].get_access_token(:oauth_verifier => oauth_verifier)
      redirect_to :root
    end
  end

  def reset
    session[:access_token] = nil
    redirect_to :root
  end

end
