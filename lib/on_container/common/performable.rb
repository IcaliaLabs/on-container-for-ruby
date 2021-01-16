# frozen_string_literal: true

require "active_support/concern"
require "on_container/common/safe_performable"

module OnContainer
  module Common
    module Performable
      extend ActiveSupport::Concern

      class_methods do
        def perform!(*args, **kargs)
          new(*args, **kargs).perform!
        end
      end
    end
  end
end