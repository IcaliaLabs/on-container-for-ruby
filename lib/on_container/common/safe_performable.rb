# frozen_string_literal: true

require 'on_container/common/performable'

module OnContainer
  module Common
    module SafePerformable
      def self.included(base)
        base.include OnContainer::Common::Performable
        base.extend ClassMethods
      end
      
      def perform(*args, **kargs)
        perform!(*args, **kargs)
      rescue
        false
      end

      module ClassMethods
        def perform(*args, **kargs)
          new(*args, **kargs).perform
        end
      end
    end
  end
end