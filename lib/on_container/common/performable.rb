# frozen_string_literal: true

module OnContainer
  module Common
    module Performable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def perform!(*args, **kargs)
          new(*args, **kargs).perform!
        end
      end
    end
  end
end