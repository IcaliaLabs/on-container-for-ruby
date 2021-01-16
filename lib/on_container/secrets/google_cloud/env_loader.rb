# frozen_string_literal: true

require "on_container/secrets/google_cloud/fetcher"

module OnContainer
  module Secrets
    module GoogleCloud
      class EnvLoader < ServiceBase
        ENV_KEY_SUFIX = '_GOOGLE_CLOUD_SECRET'
    
        def env_keys
          @env_keys ||= ENV.keys.select do |key|
            key.end_with?(ENV_KEY_SUFIX)
          end.sort
        end
    
        def env_keys?
          env_keys.any?
        end
    
        def secret_manager?
          defined?(Google::Cloud::SecretManager)
        end
    
        def perform!
          return unless env_keys? && secret_manager?
    
          env_keys.each do |key|
            ENV.merge! Fetcher.perform! ENV[key], client: client
          end
    
          true
        end
      end
    end
  end
end