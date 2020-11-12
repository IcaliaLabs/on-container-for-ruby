# frozen_string_literal: true

module OnContainer
  module Dev
    module RailsOps
      def remove_rails_pidfile
        system "rm -rf #{File.expand_path('tmp/pids/server.pid')}"
      end
      
      def rails_server?
        ARGV[0] == 'rails' && %w[server s].include?(ARGV[1])
      end
    end
  end
end