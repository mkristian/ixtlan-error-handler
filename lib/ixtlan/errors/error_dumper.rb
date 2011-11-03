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
        @keep_dumps = 0
      end

      def keep_dumps=(ttl)
        @keep_dumps = ttl.to_i
        daily_cleanup
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
          @last_cleanup = Date.today
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
