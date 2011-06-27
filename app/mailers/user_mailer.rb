class UserMailer < ActionMailer::Base
  default :from => "admin@everzealot.com"
  
  def send_image_mail(to, from, subject, message, files, type="attach")
    files.each do |file|
      ret = file.match(/\/.*\/(.*)/)
      file_name = ret[1]
      attachments[file_name] = File.read(file)      
    end
    
    mail(:to => to, :subject => subject, :from => from)
  end
end
