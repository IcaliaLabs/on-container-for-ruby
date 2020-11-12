# frozen_string_literal: true

module OnContainer
  module BundlerOps
    def ensure_project_gems_are_installed
      system 'bundle check || bundle install'
    end
  end
end