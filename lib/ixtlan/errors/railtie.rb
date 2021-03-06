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
begin
  require 'pony'
rescue LoadError
  # ignore
end
require 'ixtlan/errors/rescue_module'
require 'ixtlan/errors/error_handler'
require 'ixtlan/errors/dumper'
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

        app.config.error_dumper = Dumper.new
        app.config.skip_rescue_module = false
      end
      
      config.after_initialize do |app|
        ::ActionController::Base.send(:include, RescueModule) unless app.config.skip_rescue_module
        ::ActionController::Base.send(:include, ErrorHandler)
      end
    end
  end
end