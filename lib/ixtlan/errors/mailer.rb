module Ixtlan
  module Errors
    if defined? Pony

      class Mailer
        def error_notification(email_from, emails_to, exception, error_url)
          Pony.mail( :from => email_from,
                     :to => emails_to,
                     :subject => exception.message,
                     :body => "#{error_url}" )
        end
      end

    else
      class Mailer < ActionMailer::Base
      
        def error_notification(email_from, emails_to, exception, error_url)
          @subject    = exception.message
          @text       = "#{error_url}"
          @recipients = emails_to
          @from       = email_from
          @sent_on    = Time.now
          @headers    = {}
        end
      end
    end
  end
end
