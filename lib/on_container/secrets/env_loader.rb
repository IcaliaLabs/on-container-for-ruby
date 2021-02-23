# frozen_string_literal: true

require 'on_container/common/safe_performable'
require 'on_container/secrets/google_cloud/env_loader'
require 'on_container/secrets/mounted_files/env_loader'
require 'on_container/secrets/url_variable_processor'

module OnContainer
  module Secrets
    #= EnvLoader
    #
    # Reads the specified secret paths (i.e. Docker Secrets) into environment
    # variables:
    class EnvLoader
      include OnContainer::Common::SafePerformable

      def perform!
        load_secrets_from_google_cloud if google_cloud_secrets?
        load_secrets_from_mounted_files
        process_url_variables
        true
      end

      private

      def google_cloud_secrets?
        OnContainer::Secrets::GoogleCloud::EnvLoader.secret_manager?
      end

      def load_secrets_from_google_cloud
        OnContainer::Secrets::GoogleCloud::EnvLoader.perform!
      end

      def load_secrets_from_mounted_files
        OnContainer::Secrets::MountedFiles::EnvLoader.perform!
      end

      def process_url_variables
        OnContainer::Secrets::UrlVariableProcessor.perform!
      end
    end
  end
end
