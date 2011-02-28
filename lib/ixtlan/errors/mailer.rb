module Ixtlan
  module Errors
    class Mailer < ActionMailer::Base
      
      def error_notification(email_from, emails_to, exception, error_file)
        @subject    = exception.message
        @body       = {:text => "#{error_file}"}
        @recipients = emails_to
        @from       = email_from
        @sent_on    = Time.now
        @headers    = {}
      end
    end
  end
end
