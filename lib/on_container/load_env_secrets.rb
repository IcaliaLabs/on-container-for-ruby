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
require 'on_container/secrets/url_variable_processor'
OnContainer::Secrets::UrlVariableProcessor.perform!
