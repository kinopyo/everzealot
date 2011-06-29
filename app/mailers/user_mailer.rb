class UserMailer < ActionMailer::Base
  default :from => "admin@everzealot.com"
  
  def send_image_mail(email, files)
    files.each do |file|
      ret = file.match(/\/.*\/(.*)/)
      file_name = ret[1]
      attachments[file_name] = File.read(file)      
    end
    @message = email["message"]
    
    mail(:to => email["to_email"], :subject => email["subject"], :from => email["from_email"])
  end
end
