require 'dm-core'
module Ixtlan
  module Errors
    class Error

      include DataMapper::Resource

      property :id, Serial
      
      property :clazz, String, :required => true, :length => 64
      property :message, String, :required => true, :length => 255
      property :backtrace, Text, :required => true, :length => 32768
      property :request, Text, :required => true, :length => 64536
      property :response, Text, :required => true, :length => 32768
      property :session, Text, :required => true, :length => 16384
      property :parameters, Text, :required => true, :length => 32768
      
      property :created_at, DateTime
      
      before :save do
        self.created_at = DateTime.now
      end
    end
  end
end