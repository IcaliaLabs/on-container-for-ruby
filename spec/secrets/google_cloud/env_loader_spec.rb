
require 'on_container/secrets/google_cloud/env_loader'
require_relative '../shared/contexts/with_google_secret_manager'

RSpec.describe OnContainer::Secrets::GoogleCloud::EnvLoader, type: :env_spec do
  shared_context 'ENV with vars ending with "_GOOGLE_CLOUD_SECRET"' do
    let(:example_env_vars) { { FOO_GOOGLE_CLOUD_SECRET: 'foo' } }
  end

  describe '#env_keys' do
    context 'with no ENV vars ending with "_GOOGLE_CLOUD_SECRET"' do
      it 'is empty' do
        expect(subject.env_keys).to be_empty
      end
    end

    context 'with ENV vars ending with "_GOOGLE_CLOUD_SECRET"' do
      include_context 'ENV with vars ending with "_GOOGLE_CLOUD_SECRET"'

      it 'contains the env var name' do
        expect(subject.env_keys).to include(*example_env_vars.keys.map(&:to_s))
      end
    end
  end

  describe '#env_keys?' do
    context 'with no ENV vars ending with "_GOOGLE_CLOUD_SECRET"' do
      it 'returns false' do
        expect(subject.env_keys?).to be false
      end
    end

    context 'with ENV vars ending with "_GOOGLE_CLOUD_SECRET"' do
      include_context 'ENV with vars ending with "_GOOGLE_CLOUD_SECRET"'

      it 'returns true' do
        expect(subject.env_keys?).to be true
      end
    end
  end

  describe '#secret_manager?' do
    context 'when Google::Cloud::SecretManager is not loaded' do
      it 'returns false' do
        expect(subject.secret_manager?).to be false
      end
    end

    context 'with Google::Cloud::SecretManager loaded' do
      include_context 'with Google::Cloud::SecretManager loaded'

      it 'returns true' do
        expect(subject.env_keys?).to be false
      end
    end
  end

  describe '.secret_manager?' do
    context 'without Google::Cloud::SecretManager loaded' do
      it 'returns false' do
        expect(subject).not_to be_secret_manager
      end
    end

    context 'with Google::Cloud::SecretManager loaded' do
      include_context 'with Google::Cloud::SecretManager loaded'

      it 'returns true' do
        expect(subject).to be_secret_manager
      end
    end
  end

  describe '#perform!' do
    let(:fetcher_class) { OnContainer::Secrets::GoogleCloud::Fetcher }
    
    context 'with no ENV vars ending with "_GOOGLE_CLOUD_SECRET"' do
      context 'when Google::Cloud::SecretManager is not loaded' do
        it 'does not call the fetcher' do
          expect(fetcher_class).not_to receive(:perform!)
          subject.perform!
        end
      end

      context 'with Google::Cloud::SecretManager loaded' do
        include_context 'with Google::Cloud::SecretManager loaded'

        it 'does not call the fetcher' do
          expect(fetcher_class).not_to receive(:perform!)
          subject.perform!
        end
      end
    end
    
    context 'with ENV vars ending with "_GOOGLE_CLOUD_SECRET"' do
      include_context 'ENV with vars ending with "_GOOGLE_CLOUD_SECRET"'
      
      context 'when Google::Cloud::SecretManager is not loaded' do
        it 'does not call the fetcher' do
          expect(fetcher_class).not_to receive(:perform!)
          subject.perform!
        end
      end

      context 'with Google::Cloud::SecretManager loaded' do
        include_context 'with Google::Cloud::SecretManager loaded'

        let(:test_secret_data) { { 'UNO' => 'ONE' } }

        it 'merges the fetched data to ENV' do
          expect(ENV.to_h).not_to include test_secret_data

          expect(fetcher_class).to receive(:perform!)
            .with('foo', client: 'bar')
            .and_return(test_secret_data)
          
          subject.perform!

          expect(ENV.to_h).to include test_secret_data
        end
      end
    end
  end
end
