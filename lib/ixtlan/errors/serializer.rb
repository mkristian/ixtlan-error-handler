require 'ixtlan/babel/serializer'

module Ixtlan
  module Errors

    class ErrorSerializer < Ixtlan::Babel::Serializer

      root 'error'

      add_context( :single )

      add_context( :collection, :only => [ :id, :clazz, :message ] )

    end
  end
end