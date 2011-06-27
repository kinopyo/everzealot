class UserMailer < ActionMailer::Base
  default :from => "admin@everzealot.com"
  
  def send_image_mail(to)
    # attachments["foo.pgn"] = File.read("#{Rails.root}/public/images/rails.png")
    mail(:to => "fantasyday@hotmail.com", :subject => "Images from everzealot!", :from => "hallo@zealot.com")
  end
end
