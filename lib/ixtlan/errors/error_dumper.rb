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
require 'ixtlan/errors/mailer'
require 'fileutils'
require 'slf4r/logger'

# unless Fixnum.respond_to? :days
#   class Fixnum
#     def days
#       self
#     end
    
#     def ago
#       DateTime.now - 86000 * self
#     end
#   end
# end

module Ixtlan
  module Errors
    class ErrorDumper
      
      private

      include ::Slf4r::Logger

      public

      attr_accessor :from_email, :to_emails, :keep_dumps, :base_url

      def initialize
        @keep_dumps = 30
      end

      def keep_dumps=(ttl)
        old = @keep_dumps
        @keep_dumps = ttl.to_i
        daily_cleanup if old != @keep_dumps
      end
      
      def error_dump_model(model = nil)
        @error_dump ||= model.nil? ? ::Error : model.classify
      end

      def dump(controller, exception)
        daily_cleanup

        error = dump_environment(exception, controller)
        Mailer.error_notification(@from_email, @to_emails, exception, "#{@base_url}/#{error.id}").deliver unless (@to_emails.blank? || @from_email.blank?)
        "#{@base_url}/#{error.id}"
      end

      private

      def dump_environment(exception, controller)
        dump = error_dump_model.new
        
        dump.request = dump_hashmap(controller.request.env)

        dump.response = dump_hashmap(controller.response.headers)

        dump.session = dump_hashmap(controller.session)

        dump.parameters = dump_hashmap(controller.params)

        dump.message = exception.message
        
        dump.clazz = exception.class.to_s
        
        dump.backtrace = exception.backtrace.join("\n") if exception.backtrace

        dump if dump.save
      end

      def dump_hashmap(map, indent = '')
        result = ''
        map.each do |key,value|
          if value.is_a? Hash
            result << "#{indent}#{key} => {\n"
            result << dump_hashmap(value, "#{indent}  ") 
            result << "#{indent}}\n"
          else
            result << "#{indent}#{key} => #{value.nil? ? 'nil': value}\n"
          end
        end
        result
      end

      def daily_cleanup
        if(@last_cleanup.nil? || @last_cleanup < 1.days.ago)
          @last_cleanup = 0.days.ago # to have the right type
          begin
            delete_all
            logger.info("cleaned error dumps")
          rescue Exception => e
            logger.error("cleanup error dumps", e)
          end
        end
      end

      private
      
      if defined? ::DataMapper
        def delete_all
          error_dump_model.all(:created_at.lte => keep_dumps.days.ago).destroy!
        end
      else # ActiveRecord
        def delete_all
          error_dump_model.all(:conditions => ["created_at <= ?", keep_dumps.days.ago]).each(&:delete)
        end
      end
    end
  end
end