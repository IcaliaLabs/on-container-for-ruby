# frozen_string_literal: true

require 'on_container/common/safe_performable'

module OnContainer
  module Secrets
    #= UrlVariableProcessor
    #
    # For each *_URL environment variable where there's also a *_(USER|USERNAME)
    # or *_(PASS|PASSWORD), updates the URL environment variable with the given
    # credentials. For example:
    #
    # DATABASE_URL: postgres://postgres:5432/demo_production
    # DATABASE_USERNAME: lalito
    # DATABASE_PASSWORD: lepass
    #
    # Results in the following updated DATABASE_URL:
    #  DATABASE_URL = postgres://lalito:lepass@postgres:5432/demo_production
    class UrlVariableProcessor
      include OnContainer::Common::SafePerformable

      def perform!
        require_uri_module if url_keys?
        process_credential_keys
      end

      def url_keys
        @url_keys ||= ENV.keys.select { |key| key =~ /_URL/ }
      end

      def url_keys?
        url_keys.any?
      end
      
      private

      def process_credential_keys
        url_keys.each { |url_key| process_credential_keys_for(url_key) }
      end

      def require_uri_module
        require 'uri'
      end

      def credential_keys_for(url_key)
        credential_pattern_string = url_key
          .gsub('_URL', '_(USER(NAME)?|PASS(WORD)?)')

        credential_pattern = Regexp.new "\\A#{credential_pattern_string}\\z"
        ENV.keys.select { |key| key =~ credential_pattern }
      end

      def process_credential_keys_for(url_key)
        return unless (credential_keys = credential_keys_for(url_key)).any?

        uri = URI(ENV[url_key])

        # Reverse sorting will place "*_USER" before "*_PASS":
        credential_keys.sort.reverse.each do |credential_key|
          credential_value = URI.encode_www_form_component ENV[credential_key]
          case credential_key
          when /USER/ then uri.user = credential_value
          when /PASS/ then uri.password = credential_value
          end
        end

        ENV[url_key] = uri.to_s
      end
    end
  end
end
