class ApplicationController < ActionController::Base
  protect_from_forgery
  def is_image(mime)
    return mime =~ /^image/
  end
end
