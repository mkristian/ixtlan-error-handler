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
require 'dm-core'
module Ixtlan
  module Errors
    class Error

      include DataMapper::Resource

      def self.storage_name(arg)
        'ixtlan_errors'
      end

      property :id, Serial
      
      property :clazz, String, :required => true, :length => 64
      property :message, String, :required => true, :length => 255
      property :backtrace, Text, :required => true, :length => 32768
      property :request, Text, :required => true, :length => 32768
      property :session, Text, :required => true, :length => 16384
      property :parameters, Text, :required => false, :length => 32768
      #property :body, Text, :required => false, :length => 64536
      
      property :created_at, DateTime
      
      before :save do
        self.created_at = DateTime.now
      end

      def to_s
        "#{clazz}: #{message}"
      end
    end
  end
end
