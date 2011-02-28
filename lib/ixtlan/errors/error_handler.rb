module Ixtlan
  module Errors
    module ErrorHandler

      protected

      def internal_server_error(exception)
        dump_error(exception)
        status = :internal_server_error
        error_page(:internal_server_error, exception, "internal server error: #{exception.class.name}")
      end

      def page_not_found(exception)
        log_user_error(exception)
        status = rescue_responses[exception.class.name]
        status = status == :internal_server_error ? :not_found : status
        error_page(status, exception, "page not found")
      end

      def stale_resource(exception)
        log_user_error(exception)
        respond_to do |format|
          format.html {
            render_stale_error_page
          }
          format.xml { head :conflict }
        end
      end

      def render_error_page_with_session(status)
        render :template => "errors/error_with_session", :status => status
      end

      def render_error_page(status)
        render :template => "errors/error", :status => status
      end

      def render_stale_error_page
        render :template => "errors/stale", :status => :conflict
      end

      private

      if defined? ::Ixtlan::Audit
        def user_logger
          @user_logger ||= Ixtlan::Audit::UserLogger.new(Rails.application.config.audit_manager)
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

      def error_page(status, exception, notice)
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
        log_user_error(exception)
        Rails.configuration.error_dumper.dump(self, exception)
      end
    end
  end
end
