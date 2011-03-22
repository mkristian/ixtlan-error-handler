require 'ixtlan/errors/mailer'
require 'fileutils'

module Ixtlan
  module Errors
    class ErrorDumper
      
      attr_accessor :dump_dir, :email_from, :email_to, :keep_dumps

      def keep_dumps
        @keep_dumps ||= 90
      end

      def keep_dumps=(ttl)
        @keep_dumps = ttl.to_i
        cleanup
      end

      def dump_dir
        if @dump_dir.blank?
          @dump_dir = File.join(Rails.root, "log", "errors")
          FileUtils.mkdir_p(@dump_dir)
        end
        @dump_dir 
      end

      def dump_dir=(dir)
        @dump_dir = dir
        FileUtils.mkdir_p(@dump_dir) unless dir.blank?
        @dump_dir
      end
      
      def dump(controller, exception)
        cleanup
        log_file = log_filename
        logger = Logger.new(log_file)

        dump_environment(logger, exception, controller)
        Mailer.error_notification(@email_from, @email_to, exception, log_file).deliver unless (@email_to.blank? || @email_from.blank?)
        log_file
      end

      private

      def log_filename(time = Time.now)
        error_log_id = "#{time.tv_sec}#{time.tv_usec}"
        File.join(dump_dir, "error-#{error_log_id}.log")
      end

      def dump_environment_header(logger, header)
        logger.error("\n===================================================================\n#{header}\n===================================================================\n");
      end

      def dump_environment(logger, exception, controller)
        dump_environment_header(logger, "REQUEST DUMP");
        dump_hashmap(logger, controller.request.env)

        dump_environment_header(logger, "RESPONSE DUMP");
        dump_hashmap(logger, controller.response.headers)

        dump_environment_header(logger, "SESSION DUMP");
        dump_hashmap(logger, controller.session)

        dump_environment_header(logger, "PARAMETER DUMP");
        map = {}
        dump_hashmap(logger, controller.params.each{ |k,v| map[k]=v })

        dump_environment_header(logger, "EXCEPTION");
        logger.error("#{exception.class}:#{exception.message}")
        logger.error("\t" + exception.backtrace.join("\n\t")) if exception.backtrace
      end

      def dump_hashmap(logger, map)
        for key,value in map
          logger.error("\t#{key} => #{value.inspect}")
        end
      end

      def cleanup
        ref_log_file = log_filename(keep_dumps.ago)
        Dir[File.join(dump_dir, "error-*.log")].each do |f|
          FileUtils.rm(f) if File.basename(f) < ref_log_file
        end
      end
    end
  end
end
