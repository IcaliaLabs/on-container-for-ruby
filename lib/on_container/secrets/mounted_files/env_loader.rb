# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object'
require 'on_container/common/safe_performable'

module OnContainer
  module Secrets
    module MountedFiles
      class EnvLoader
        include OnContainer::Common::SafePerformable

        def perform!
          setup_secrets_path
          scan_secrets_path_for_files
          load_secret_files_to_env_vars
        end

        def secrets_path
          @secrets_path ||= ENV.fetch('SECRETS_PATH', '/run/secrets')
        end

        def secret_mounted_file_paths
          @secret_mounted_file_paths ||= Dir["#{secrets_path}/**/*"]
            .map { |path| Pathname.new(path) }
            .select(&:file?)
        end

        private

        alias setup_secrets_path secrets_path
        alias scan_secrets_path_for_files secret_mounted_file_paths

        def load_secret_files_to_env_vars
          return if @already_loaded

          secret_mounted_file_paths
            .each { |file_path| load_secret_file_to_env_var(file_path) }

          @already_loaded = true
        end

        def load_secret_file_to_env_var(file_path)
          env_var_name = file_path.basename('.*').to_s.upcase

          # Skip if variable is already set - already-set variables have
          # precedence over the secret files:
          return if ENV.key?(env_var_name) && ENV[env_var_name].present?

          contents = file_path.read.strip

          # TODO: Do not load if content has null bytes
          ENV[env_var_name] = file_path.read.strip
        end
      end
    end
  end
end
