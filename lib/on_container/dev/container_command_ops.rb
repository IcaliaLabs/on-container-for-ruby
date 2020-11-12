# frozen_string_literal: true

module OnContainer
  module Dev
    module ContainerCommandOps
      def set_given_or_default_command
        ARGV.concat %w[rails server -p 3000 -b 0.0.0.0] if ARGV.empty?
      end
      
      def execute_given_or_default_command
        exec(*ARGV)
      end
    end
  end
end

