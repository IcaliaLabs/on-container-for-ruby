# frozen_string_literal: true

require 'on_container/dev/rails_ops'
require 'on_container/dev/setup_ops'
require 'on_container/dev/bundler_ops'
require 'on_container/dev/node_modules_ops'
require 'on_container/dev/active_record_ops'
require 'on_container/dev/container_command_ops'

include OnContainer::Dev::RailsOps
include OnContainer::Dev::SetupOps
include OnContainer::Dev::BundlerOps
include OnContainer::Dev::NodeModulesOps
include OnContainer::Dev::ActiveRecordOps
include OnContainer::Dev::ContainerCommandOps