# frozen_string_literal: true

require "active_support/concern"
require "on_container/common/performable"

module OnContainer
  module Common
    module SafePerformable
      extend ActiveSupport::Concern

      included do
        include OnContainer::Common::Performable
      end
      
      def perform(*args, **kargs)
        perform!(*args, **kargs)
      rescue
        false
      end

      class_methods do
        def perform(*args, **kargs)
          new(*args, **kargs).perform
        end
      end
    end
  end
end