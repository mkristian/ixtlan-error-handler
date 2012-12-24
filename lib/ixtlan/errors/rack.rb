module Ixtlan
  module Errors
    class Rack

      DEFAULT_MAP = {}

      # conflict
      DEFAULT_MAP[ 409 ] = []
      if defined? ::Ixtlan::Optimistic
        DEFAULT_MAP[ 409 ] << ::Ixtlan::Optimistic::ObjectStaleException
      end

      # not found
      DEFAULT_MAP[ 404 ] = []
      if defined? ::Ixtlan::Guard
        DEFAULT_MAP[ 404 ] << ::Ixtlan::Guard::GuardException
        DEFAULT_MAP[ 404 ] << ::Ixtlan::Guard::PermissionDenied
      end
      if defined? ::DataMapper
        DEFAULT_MAP[ 404 ] << ::DataMapper::ObjectNotFoundError
      end
      if defined? ::ActiveRecord
        DEFAULT_MAP[ 404 ] << ::ActiveRecord::RecordNotFound
      end

      def initialize(app, dumper, dump_to_console = false, map = {} )
        @app = app
        @dumper = dumper
        @dump_to_console = dump_to_console
        @map = {}
        DEFAULT_MAP.each do |status, list|
          list.each { |exp| @map[ exp ] = status }
        end
        map.each do |status, list|
          list.each { |exp| @map[ exp ] = status }
        end
      end
      
      def call(env)
        begin
          @app.call(env)
        rescue Exception => e
          status = @map[ e.class ] || 500
          if status >= 500 
            @dumper.dump( e, env, {}, {}, {} )
          end
          if @dump_to_console
            warn "[Ixtlan] #{e.class}: #{e.message}"
            warn "\t" + e.backtrace.join( "\n\t" ) if e.backtrace && status >= 500 
          end
          [ status, 
            {'Content-Type' =>  'text/plain'}, 
            [''] ]
        end
      end
      
    end
  end
end