#
# Copyright (C) 2012 mkristian
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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