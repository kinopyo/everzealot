class UserMailer < ActionMailer::Base
  default :from => "someone@gmail.com"
  
  def send_image_mail(email)
    # attachments["foo.pgn"] = File.read("#{Rails.root}/public/images/rails.png")
    mail(:to => email, :subject => "Images from everzealot!")
  end
end
