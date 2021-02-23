# frozen_string_literal: true

# This script achieves a list of secret loading & processing:
#
# 1. Loads secrets from Google Cloud Secret Manager to ENV, if configured.
# 2. Reads files in a configured Folder, and loads them into ENV variables.
# 3. Processes "*_URL" env vars, adding their respective "*_USER" and "*_PASS".
#
# - See https://github.com/IcaliaLabs/on-container-for-ruby#loading-secrets-into-environment-variables

require 'on_container/secrets/env_loader'
OnContainer::Secrets::EnvLoader.perform!
