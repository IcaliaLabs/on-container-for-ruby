# frozen_string_literal: true

# Reads the specified secret paths (i.e. Docker Secrets) into environment
# variables:

# Load secrets from Google Cloud Secret Manager to ENV, if any:
require 'on_container/secrets/google_cloud/env_loader'
OnContainer::Secrets::GoogleCloud::EnvLoader.perform!

# Process only a known list of env vars that can filled by reading a file (i.e.
# a docker secret):
require 'on_container/secrets/mounted_files/env_loader'
OnContainer::Secrets::MountedFiles::EnvLoader.perform!

# For each *_URL environment variable where there's also a *_(USER|USERNAME) or
# *_(PASS|PASSWORD), update the URL environment variable with the given
# credentials. For example:
#
# DATABASE_URL: postgres://postgres:5432/demo_production
# DATABASE_USERNAME: lalito
# DATABASE_PASSWORD: lepass
#
# Results in the following updated DATABASE_URL:
#  DATABASE_URL = postgres://lalito:lepass@postgres:5432/demo_production
require 'uri' if (url_keys = ENV.keys.select { |key| key =~ /_URL/ }).any?

url_keys.each do |url_key|
  credential_pattern_string = url_key.gsub('_URL', '_(USER(NAME)?|PASS(WORD)?)')
  credential_pattern = Regexp.new "\\A#{credential_pattern_string}\\z"
  credential_keys = ENV.keys.select { |key| key =~ credential_pattern }
  next unless credential_keys.any?

  uri = URI(ENV[url_key])

  credential_keys.each do |credential_key|
    credential_value = URI.encode_www_form_component ENV[credential_key]
    case credential_key
    when /USER/ then uri.user = credential_value
    when /PASS/ then uri.password = credential_value
    end
  end

  ENV[url_key] = uri.to_s
end

# STDERR.puts ENV.inspect
