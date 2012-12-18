require 'rails'
require 'ixtlan/errors/rescue_module'
require 'ixtlan/errors/error_handler'
require 'ixtlan/errors/error_dumper'

module Ixtlan
  module Errors
    class Railtie < Rails::Railtie

      config.before_configuration do |app|

        unless defined? Pony
          path = File.join(File.dirname(__FILE__), "..", "..")
          unless ActionMailer::Base.view_paths.member? path
            ActionMailer::Base.view_paths= [ActionMailer::Base.view_paths, path].flatten 
          end
        end

        app.config.error_dumper = ErrorDumper.new
        app.config.skip_rescue_module = false
      end
      
      config.after_initialize do |app|
        ::ActionController::Base.send(:include, RescueModule) unless app.config.skip_rescue_module
        ::ActionController::Base.send(:include, ErrorHandler)
      end
    end
  end
end
