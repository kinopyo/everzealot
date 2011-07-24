class UserMailer < ActionMailer::Base
  default :from => "admin@everzealot.com"
  ADMIN_EMAIL = "fantasyday@gmail.com"
  
  def send_image_mail(email, files)
    files.each do |file|
      res = file.match(/\/.*\/(.*)/)
      file_name = res[1]
      if email["attach"] == true  # inline attachment
        @inline = true
        attachments.inline[file_name] = File.read(file)  
      else
        @inline = false
        attachments[file_name] = File.read(file)      
      end
    end

    @email = email
    options = {:to => email["to_email"], :subject => email["subject"], :from => email["from_email"]}
    options[:cc] = email["from_email"] unless email["cc"].blank?  
    mail(options)
  end
  
  def send_feedback(feedback)                                                                                 
    @message = feedback["message"]
    mail(:to => ADMIN_EMAIL, :subject => "New Feedback by #{feedback["username"]}", :from => feedback["email"])
  end
end
