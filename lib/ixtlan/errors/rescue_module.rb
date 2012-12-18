module Ixtlan
  module Errors
    module RescueModule
      def self.included(controller)
         if defined? ::Ixtlan::ModifiedBy
           # needs 'optimistic_persistence'
           controller.rescue_from ::Ixtlan::ModifiedBy::StaleResourceError, :with => :stale_resource
         end
         if defined? ::Ixtlan::Optimistic
           # needs 'optimistic_persistence'
           controller.rescue_from ::Ixtlan::Optimistic::ObjectStaleException, :with => :stale_resource
         end

        if defined? ::Ixtlan::Guard
          # needs 'guard'
          controller.rescue_from ::Ixtlan::Guard::GuardException, :with => :page_not_found
          controller.rescue_from ::Ixtlan::Guard::PermissionDenied, :with => :page_not_found
        end
        
        if defined? ::DataMapper
          # datamapper
          controller.rescue_from ::DataMapper::ObjectNotFoundError, :with => :page_not_found
        end

        if defined? ::ActiveRecord
          # activerecord
          controller.rescue_from ::ActiveRecord::RecordNotFound, :with => :page_not_found
        end

        # standard rails controller
        controller.rescue_from ::ActionController::RoutingError, :with => :page_not_found

        if defined? ::AbstractController::ActionNotFound
          controller.rescue_from ::AbstractController::ActionNotFound, :with => :page_not_found
        else
          controller.rescue_from ::ActionController::UnknownAction, :with => :page_not_found
        end
        controller.rescue_from ::ActionController::MethodNotAllowed, :with => :page_not_found
        controller.rescue_from ::ActionController::NotImplemented, :with => :page_not_found
        controller.rescue_from ::ActionController::InvalidAuthenticityToken, :with => :stale_resource
        
        # have nice stacktraces in development mode
        unless Rails.application.config.consider_all_requests_local
          controller.rescue_from ::ActionView::MissingTemplate, :with => :internal_server_error
          controller.rescue_from ::ActionView::TemplateError, :with => :internal_server_error
          controller.rescue_from ::Exception, :with => :internal_server_error
        end
      end
    end
  end
end
