class UserMailer < ActionMailer::Base
  default :from => "admin@everzealot.com"
  ADMIN_EMAIL = "fantasyday@gmail.com"
  
  def send_image_mail(email, files)
    files.each do |file|
      ret = file.match(/\/.*\/(.*)/)
      file_name = ret[1]
      attachments[file_name] = File.read(file)      
    end
    @message = email["message"]
    
    mail(:to => email["to_email"], :subject => email["subject"], :from => email["from_email"])
  end
  
  def send_feedback(feedback)                                                                                 
    @message = feedback["message"]
    mail(:to => ADMIN_EMAIL, :subject => "New Feedback by #{feedback["username"]}", :from => feedback["email"])
  end
end
