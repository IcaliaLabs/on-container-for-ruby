
require 'on_container/secrets/url_variable_processor'

RSpec.describe OnContainer::Secrets::UrlVariableProcessor, type: :env_spec do
  shared_context 'with some url + user + pass env vars set up' do
    let :example_env_vars do
      {
        EXAMPLE_URL: 'https://example.com',
        EXAMPLE_USER: 'example-user',
        EXAMPLE_PASS: 'example-pass',
      }
    end
  end

  describe '#url_keys' do
    context 'with no url env vars set up' do
      it 'is empty' do
        expect(subject.url_keys).to be_empty
      end
    end

    context 'with "*_URL" env vars' do
      include_context 'with some url + user + pass env vars set up'

      it 'contains entries' do
        expect(subject.url_keys).to be_any
      end
    end
  end

  describe '#url_keys?' do
    context 'with no url env vars set up' do
      it 'is false' do
        expect(subject).not_to be_url_keys
      end
    end

    context 'with "*_URL" env vars' do
      include_context 'with some url + user + pass env vars set up'

      it 'is true' do
        expect(subject).to be_url_keys
      end
    end
  end

  describe '#perform!' do
    context 'with no url env vars set up' do
      it 'does not change any env var' do
        expect { subject.perform! }.not_to change { ENV.keys.count }
      end
    end

    context 'with matching "*_URL", "*_USER" and "*_PASS" env vars' do
      include_context 'with some url + user + pass env vars set up'

      it 'adds the matching credentials to the "*_URL" env var' do
        expect { subject.perform! }
          .to change { ENV['EXAMPLE_URL'] }
          .from('https://example.com')
          .to 'https://example-user:example-pass@example.com'
      end

      context 'with "*_PASS" processed before "*_USER" (is it possible?)' do
        let :example_env_vars do
          {
            EXAMPLE_PASS: 'example-pass',
            EXAMPLE_USER: 'example-user',
            EXAMPLE_URL: 'https://example.com'
          }
        end

        it 'adds the matching credentials to the "*_URL" env var' do
          expect { subject.perform! }
            .to change { ENV['EXAMPLE_URL'] }
            .from('https://example.com')
            .to 'https://example-user:example-pass@example.com'
        end
      end
    end
  end
end
