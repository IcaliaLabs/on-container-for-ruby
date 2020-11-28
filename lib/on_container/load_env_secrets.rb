# frozen_string_literal: true

# Reads the specified secret paths (i.e. Docker Secrets) into environment
# variables:

require 'active_support'
require 'active_support/core_ext/object'

# Process only a known list of env vars that can filled by reading a file (i.e.
# a docker secret):
Dir["#{ENV.fetch('SECRETS_PATH', '/run/secrets/')}*"].each do |secret_filepath|
  next unless File.file?(secret_filepath)

  secret_envvarname = File.basename(secret_filepath, '.*').upcase

  # Skip if variable is already set - already-set variables have precedence over
  # the secret files:
  next if ENV.key?(secret_envvarname) && ENV[secret_envvarname].present?

  ENV[secret_envvarname] = File.read(secret_filepath).strip
end

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
  username = URI.encode_www_form_component ENV[credential_keys.detect { |key| key =~ /USER/ }]
  password = URI.encode_www_form_component ENV[credential_keys.detect { |key| key =~ /PASS/ }]

  uri.user = username if username
  uri.password = password if password
  ENV[url_key] = uri.to_s
end

# STDERR.puts ENV.inspect