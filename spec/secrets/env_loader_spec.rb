
require 'on_container/secrets/env_loader'
require_relative 'shared/contexts/with_google_secret_manager'

RSpec.describe OnContainer::Secrets::EnvLoader, type: :env_spec do
  describe '#perform!' do
    context 'with Google::Cloud::SecretManager loaded' do
      include_context 'with Google::Cloud::SecretManager loaded'
      
      it 'performs the google secrets manager env loader service' do
        expect(OnContainer::Secrets::GoogleCloud::EnvLoader)
          .to receive(:perform!).ordered
        subject.perform!
      end

      it "performs the mounted file env loader service after google's" do
        expect(OnContainer::Secrets::GoogleCloud::EnvLoader)
          .to receive(:perform!).ordered
        
        expect(OnContainer::Secrets::MountedFiles::EnvLoader)
          .to receive(:perform!).ordered

        subject.perform!
      end

      it "performs the mounted url env processor service last" do
        expect(OnContainer::Secrets::GoogleCloud::EnvLoader)
          .to receive(:perform!).ordered
        
        expect(OnContainer::Secrets::MountedFiles::EnvLoader)
          .to receive(:perform!).ordered
    
        expect(OnContainer::Secrets::UrlVariableProcessor)
          .to receive(:perform!).ordered

        subject.perform!
      end
    end

    context 'without Google::Cloud::SecretManager loaded' do
      it 'does not perform the google secrets manager env loader service' do
        expect(OnContainer::Secrets::GoogleCloud::EnvLoader)
          .not_to receive(:perform!)

        subject.perform!
      end

      it "performs the mounted file env loader" do
        expect(OnContainer::Secrets::MountedFiles::EnvLoader)
          .to receive(:perform!).ordered

        subject.perform!
      end

      it "performs the mounted url env processor service last" do
        expect(OnContainer::Secrets::MountedFiles::EnvLoader)
          .to receive(:perform!).ordered
    
        expect(OnContainer::Secrets::UrlVariableProcessor)
          .to receive(:perform!).ordered

        subject.perform!
      end
    end
  end
end
