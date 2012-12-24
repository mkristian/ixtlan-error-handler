require 'cuba_api'
require 'ixtlan/errors/resource'
require 'ixtlan/errors/serializer'
module Ixtlan
  module Errors
    class Cuba < ::CubaAPI
      define do
        on get, :number do |number|
          write Ixtlan::Errors::Error.get!( number )
        end
        on get do
          write Ixtlan::Errors::Error.all.reverse
        end
      end
    end
  end
end