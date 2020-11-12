# frozen_string_literal: true

module OnContainer
  module Dev
    module SetupOps
      APP_PATH = File.expand_path '.'
  
      def app_temp_path; "#{APP_PATH}/tmp"; end
      def app_setup_wait; ENV.fetch('APP_SETUP_WAIT', '5').to_i; end
      def app_setup_lock_path; "#{app_temp_path}/setup.lock"; end
  
      def lock_setup
        system "mkdir -p #{APP_TEMP_PATH} && touch #{APP_SETUP_LOCK};"
      end
      
      def unlock_setup
        system "rm -rf #{APP_SETUP_LOCK}"
      end
      
      def wait_setup
        puts 'Waiting for app setup to finish...'
        sleep APP_SETUP_WAIT
      end
      
      def on_setup_lock_acquired
        wait_setup while File.exist?(APP_SETUP_LOCK)
      
        lock_setup
        yield
        unlock_setup
      end

      def command_requires_setup?
        %w[
          rails rspec sidekiq hutch puma rake webpack webpack-dev-server
        ].include?(ARGV[0])
      end
    end
  end
end