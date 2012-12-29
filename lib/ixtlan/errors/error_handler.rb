#
# Copyright (C) 2012 Christian Meier
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
    module ErrorHandler

      protected

      def internal_server_error(exception)
        log_user_error(exception)
        dump_error(exception)
        error_page(:internal_server_error, "internal server error: #{exception.class.name}")
      end

      def page_not_found(exception)
        log_user_error(exception)
        error_page(:not_found, "page not found")
      end

      def stale_resource(exception)
        log_user_error(exception)
        error_page(:conflict, "stale resource")
      end

      def render_error_page_with_session(status)
        render :template => "errors/error_with_session", :status => status
      end

      def render_error_page(status)
        render :template => "errors/error", :status => status
      end

      private

      if defined? ::Ixtlan::Audit
        def user_logger
          @user_logger ||= Ixtlan::Audit::UserLogger.new(Rails.configuration.audit_manager)
        end

        def log_user_error(exception)
          user_logger.log_action(self, " - #{exception.class} - #{exception.message}")
          logger.error(exception)
        end
      else
        def log_user_error(exception)
          logger.error(exception)
        end
      end

      def error_page(status, notice)
        respond_to do |format|
          format.html {
            @notice = notice
            if respond_to?(:current_user) && current_user
              render_error_page_with_session(status)
            else
              render_error_page(status)
            end
          }
          format.xml { head status }
          format.json { head status }
        end
      end

      def dump_error(exception)
        Rails.configuration.error_dumper.dump( exception, 
                                               request.env,
                                               response.headers,
                                               session,
                                               params )
      end
    end
  end
end
