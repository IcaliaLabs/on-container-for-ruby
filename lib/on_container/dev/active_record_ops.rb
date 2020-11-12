# frozen_string_literal: true


module OnContainer
  module Dev
    module ActiveRecordOps
      def app_setup_wait
        ENV.fetch('APP_SETUP_WAIT', '5').to_i
      end

      def parse_activerecord_config_file
        require 'erb'
        require 'yaml'

        database_yaml = Pathname.new File.expand_path('config/database.yml')
        loaded_yaml = YAML.load(ERB.new(database_yaml.read).result) || {}
        shared = loaded_yaml.delete('shared')
      
        loaded_yaml.each { |_k, values| values.reverse_merge!(shared) } if shared
        Hash.new(shared).merge(loaded_yaml)
      end
      
      def activerecord_config
        @activerecord_config ||= parse_activerecord_config_file 
          .fetch ENV.fetch('RAILS_ENV', 'development')
      end
      
      def establish_activerecord_database_connection
        unless defined?(ActiveRecord)
          require 'rubygems'
          require 'bundler'

          Bundler.setup(:default)

          require 'active_record'
        end

        ActiveRecord::Base.establish_connection activerecord_config
        ActiveRecord::Base.connection_pool.with_connection { |connection| }
      end
      
      def activerecord_database_initialized?
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          connection.data_source_exists? :schema_migrations
        end
      end
      
      def activerecord_database_ready?
        connection_tries ||= 3

        establish_activerecord_database_connection
        activerecord_database_initialized?
      
      rescue PG::ConnectionBad
        unless (connection_tries -= 1).zero?
          puts "Retrying DB connection #{connection_tries} more times..."
          sleep app_setup_wait
          retry
        end
        false
      
      rescue ActiveRecord::NoDatabaseError
        false
      end
      
      def setup_activerecord_database
        system 'rails db:setup'
      end
    end
  end
end

