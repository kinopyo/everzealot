require "development_mail_interceptor"

# ActionMailer::Base.smtp_settings = {
#   :address              => "smtp.gmail.com",
#   :port                 => 587,
#   :domain               => "localhost",
#   :authentication       => :plain,
#   :user_name            => "<username>",
#   :password             => "<password>",
#   :authentication       => "plain",
#   :enable_starttls_auto => true
# }

# ActionMailer::Base.default_url_options[:host] = "0.0.0.0:3000"
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?