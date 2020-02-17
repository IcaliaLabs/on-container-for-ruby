# frozen_string_literal: true

require 'etc'

module OnContainer
  class StepDownFromRoot
    attr_reader :curent_user, :target_user
    
    def initialize
      @curent_user = Etc.getpwuid
    end

    def target_user
      @target_user ||= Etc.getpwuid(developer_uid)
    end

    def perform
      return unless root_user?
      return warn_no_developer_uid unless developer_uid?

      switch_to_developer_user
    end

    def root_user?
      curent_user.name == 'root'
    end

    def developer_uid?
      developer_uid > 0
    end

    def developer_uid
      @developer_uid ||= ENV.fetch('DEVELOPER_UID', '').to_i
    end

    protected

    def switch_to_developer_user
      target_user_name = target_user.name
      puts "Switching from 'root' user to '#{target_user_name}'..."
      Kernel.exec 'su-exec', target_user_name, $0, *$*
    end

    def warn_no_developer_uid
      puts "The 'DEVELOPER_UID' environment variable is not set... " \
           'still running as root!'
    end

    def self.perform
      new.perform
    end
  end
end

OnContainer::StepDownFromRoot.perform