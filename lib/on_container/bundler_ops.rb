# frozen_string_literal: true

module OnContainer
  module BundlerOps
    def ensure_gem_dependencies_are_met
      system 'bundle check || bundle install'
    end
  end
end