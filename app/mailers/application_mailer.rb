class ApplicationMailer < ActionMailer::Base
  default from: 'sample-app-no-reply@gmail.com'
  layout 'mailer'
end
