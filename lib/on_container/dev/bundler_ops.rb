# frozen_string_literal: true

module OnContainer
  module Dev
    module BundlerOps
      def bundle_path
        '/usr/local/bundle'
      end
  
      def bundle_owner_id
        File.stat(bundle_path).uid
      end
  
      def current_user_id
        Etc.getpwuid.uid
      end
  
      def bundle_belongs_to_current_user?
        bundle_owner_id == current_user_id
      end
      
      def make_bundle_belong_to_current_user
        target_ownership = "#{current_user_id}:#{current_user_id}"
        system "sudo chown -R #{target_ownership} #{bundle_path}"
      end
      
      def ensure_bundle_belongs_to_current_user
        return if bundle_belongs_to_current_user?
      
        make_bundle_belong_to_current_user
      end

      def ensure_project_gems_are_installed
        ensure_bundle_belongs_to_current_user

        system 'bundle check || bundle install'
      end
    end
  end
end