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
require 'rack/request'
require 'rack/utils'
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

      def initialize(app, dumper, map = {} )
        @app = app
        @dumper = dumper
        @map = {}
        DEFAULT_MAP.each do |status, list|
          list.each { |exp| @map[ exp ] = status }
        end
        map.each do |status, list|
          list.each { |exp| @map[ exp ] = status }
        end
      end
      
      def dump_to_console
        @dumper.keep_dumps == 0
      end

      def call(env)
        begin
          @app.call(env)
        rescue Exception => e
          status = @map[ e.class ] || 500
          if status >= 500
            req = ::Rack::Request.new env
            @dumper.dump( e, env, {}, req.session, req.params )
          end
          warn "[Ixtlan::Errors] #{e.class}: #{e.message}"
          if dump_to_console
            # dump to console and raise exception to let rack create
            # an error page
            warn "\t" + e.backtrace.join( "\n\t" ) if e.backtrace && status >= 500
          end
          [ status, 
            {'Content-Type' =>  'text/plain'}, 
            [ ::Rack::Utils::HTTP_STATUS_CODES[ status ] ] ]
        end
      end
      
    end
  end
end
