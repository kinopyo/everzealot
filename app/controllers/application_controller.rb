class ApplicationController < ActionController::Base
  protect_from_forgery
  def is_image(mime)
    return mime =~ /^image/
  end
  
  def login?
    return !session[:access_token].nil?
  end
end
