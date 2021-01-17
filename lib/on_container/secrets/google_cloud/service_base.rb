# frozen_string_literal: true

require "on_container/common/safe_performable"

module OnContainer
  module Secrets
    module GoogleCloud
      class ServiceBase
        include OnContainer::Common::SafePerformable
        
        attr_reader :client
    
        def client
          @client ||= Google::Cloud::SecretManager.secret_manager_service
        end
      end
    end
  end
end
