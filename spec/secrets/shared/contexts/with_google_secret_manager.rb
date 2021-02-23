RSpec.shared_context 'with Google::Cloud::SecretManager loaded' do
  around do |example|
    module ::Google
      module Cloud
        module SecretManager
          def self.secret_manager_service
            'bar'
          end
        end
      end
    end

    example.run
    
    Google::Cloud.send(:remove_const, :SecretManager)
    Google.send(:remove_const, :Cloud)
    Object.send(:remove_const, :Google)
  end
end
