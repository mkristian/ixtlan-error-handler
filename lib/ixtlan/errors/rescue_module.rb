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