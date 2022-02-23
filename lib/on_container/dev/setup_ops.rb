# frozen_string_literal: true

module OnContainer
  module Dev
    module SetupOps
      APP_PATH = File.expand_path '.'
      TRUEISH_VALUES = %w[true True TRUE yes Yes YES].freeze
      SKIP_SETUP_ENV_VAR = 'ON_CONTAINER_SKIP_SETUP_LOCK'.freeze

      def app_temp_path
        "#{APP_PATH}/tmp"
      end

      def app_setup_wait
        ENV.fetch('APP_SETUP_WAIT', '5').to_i
      end

      def app_setup_lock_path
        "#{app_temp_path}/setup.lock"
      end

      def lock_setup
        system "mkdir -p #{app_temp_path} && touch #{app_setup_lock_path};"
      end

      def unlock_setup
        system "rm -rf #{app_setup_lock_path}"
      end

      def wait_setup
        puts 'Waiting for app setup to finish...'
        sleep app_setup_wait
      end

      def on_setup_lock_acquired
        return yield if TRUEISH_VALUES.include? ENV[SKIP_SETUP_ENV_VAR]

        wait_setup while File.exist?(app_setup_lock_path)

        lock_setup

        %w[HUP INT QUIT TERM EXIT].each do |signal_string|
          Signal.trap(signal_string) { unlock_setup }
        end

        yield
      ensure
        unlock_setup
      end

      def command_requires_setup?
        %w[
          rails rspec sidekiq hutch puma rake webpack webpack-dev-server
        ].include?(ARGV[0])
      end

      def command_might_require_database?
        %w[
          rails rspec sidekiq hutch puma rake
        ].include?(ARGV[0])
      end
    end
  end
end
