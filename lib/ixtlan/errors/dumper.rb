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
require 'ixtlan/errors/mailer'
require 'fileutils'

module Ixtlan
  module Errors
    class Dumper
      
      private

      if defined? ::Slf4r
        include ::Slf4r::Logger
      else
        require 'logger'
        def logger
          @logger ||= Logger.new( STDOUT )
        end
      end

      public

      attr_accessor :model, :block, :from_email, :to_emails, :keep_dumps, :base_url

      def initialize( model = nil, &block )
        @model = model
        @keep_dumps = 30
        block.call( self ) if block
        @block = block
      end

      def model
        @model ||= (Ixtlan::Errors::Error rescue nil)
      end

      def keep_dumps=(ttl)
        old = @keep_dumps
        @keep_dumps = ttl.to_i
        daily_cleanup if old != @keep_dumps
      end
      
      def dump( exception, request, response, session , params )
        update_config

        daily_cleanup

        error = dump_environment( exception, 
                                  request, 
                                  response, 
                                  session, 
                                  params )

        if not error.id.nil? and not @to_emails.blank? and not @from_email.blank?
          Mailer.error_notification( @from_email, 
                                     @to_emails, 
                                     exception, 
                                     "#{@base_url}/#{error.id}" ).deliver
          true
        else
          false
        end
      end

      private

      def update_config
        block.call( self ) if block
      end

      def dump_environment( exception, request, response, session , params )
        dump = model.new
        
        dump.request = dump_hashmap( request, '', true )

        dump.session = dump_hashmap( session )

        dump.parameters = dump_hashmap( params )

        dump.message = exception.message
        
        dump.clazz = exception.class.to_s
        
        dump.backtrace = exception.backtrace.join("\n") if exception.backtrace
        
        dump.save
        dump
      end

      def dump_hashmap(map, indent = '', capital_keys_only = false )
        result = ''
        map.each do |key,value|
          if !capital_keys_only || (key =~ /^[A-Z_]+$/) != nil
          if value.is_a? Hash
            result << "#{indent}#{key} => {\n"
            result << dump_hashmap(value, "#{indent}  ") 
            result << "#{indent}}\n"
          else
            result << "#{indent}#{key} => #{value.nil? ? 'nil': value}\n"
          end
          end
        end
        result.strip!
        result
      end

      def daily_cleanup
        return unless model
        now = DateTime.now
        if(@last_cleanup.nil? || @last_cleanup < (now - 1))
          @last_cleanup = now
          begin
            delete_all( now - keep_dumps )
            logger.info "cleaned error dumps"
          rescue Exception => e
            logger.warn "error cleaning up error dumps: #{e.message}" 
          end
        end
      end

      private
      
      if defined? ::DataMapper
        def delete_all( expired )
          model.all( :created_at.lte => expired ).destroy!
        end
      else # ActiveRecord
        def delete_all( expired )
          model.all( :conditions => ["created_at <= ?", expired] ).each(&:delete)
        end
      end
    end
  end
end
