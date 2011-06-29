class Email < ActiveRecord::Base
  ### Validations
  email_reg = /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates :from_email, :presence => true, :format => {:with => email_reg}
  validates :to_email, :presence => true, :format => {:with => email_reg}
  validates :subject, :presence => true
  validates :message, :length => {:maximum => 500}
                        
end
