# frozen_string_literal: true

require 'yaml'
require 'on_container/secrets/google_cloud/service_base'

module OnContainer
  module Secrets
    module GoogleCloud
      class Fetcher < ServiceBase
        PROJECT_PATTERN = %r{\Aprojects\/(\w+)\/.*}.freeze
        SECRET_NAME_PATTERN = %r{secrets\/([\w-]+)\/?}.freeze
        SECRET_VERSION_PATTERN = %r{versions\/(\d+|latest)\z}.freeze
        
        attr_reader :project, :secret_name, :secret_version
    
        def initialize(given_key, client: nil)
          @client = client
          @project = extract_project given_key
          @secret_version = extract_secret_version given_key
          @secret_name = extract_secret_name given_key
        end
    
        def perform!
          # Build the resource name of the secret version.
          name = client.secret_version_path project:        @project,
                                            secret:         @secret_name,
                                            secret_version: @secret_version
      
          version = client.access_secret_version name: name
      
          YAML.load version.payload.data
        end
    
        protected
    
        def default_project
          ENV['GOOGLE_CLOUD_PROJECT']
        end
    
        def extract_project(given_key)
          match = given_key.match(PROJECT_PATTERN)
          return default_project unless match
    
          match.captures.first
        end
    
        def extract_secret_version(given_key)
          match = given_key.match(SECRET_VERSION_PATTERN)
          return 'latest' unless match
    
          match.captures.first
        end
    
        def extract_secret_name(given_key)
          given_key
            .sub("projects/#{@project}/secrets/", '')
            .sub("/versions/#{@secret_version}", '')
        end
      end
    end
  end
end