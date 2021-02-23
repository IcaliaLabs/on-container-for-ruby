
require 'on_container/secrets/mounted_files/env_loader'

RSpec.describe OnContainer::Secrets::MountedFiles::EnvLoader do
  def with_modified_env(options, &block)
    keys_before_example = ENV.keys + %w[LINES COLUMNS]
    ClimateControl.modify(options, &block)
    (ENV.keys - keys_before_example).each { |added_key| ENV.delete added_key }
  end

  let :example_secrets_path do
    rel_path = File.join '..', '..', 'fixtures', 'mounted_secret_files'
    File.expand_path rel_path, __dir__
  end

  let(:test_env_vars) { {} }

  around do |example|
    with_modified_env(test_env_vars) { example.run }
  end

  shared_context 'with "SECRETS_PATH" set up' do
    let(:test_env_vars) { { SECRETS_PATH: example_secrets_path } }
  end

  describe '#secrets_path' do
    it 'is the default path "/run/secrets"' do
      expect(subject.secrets_path).to eq '/run/secrets'
    end

    context 'with "SECRETS_PATH" set up' do
      include_context 'with "SECRETS_PATH" set up'
      
      it 'points to the path in "SECRETS_PATH" env variable' do
        expect(subject.secrets_path).to eq example_secrets_path
      end
    end
  end

  describe '#secret_mounted_file_paths' do
    it 'is empty' do
      expect(subject.secret_mounted_file_paths).to be_empty
    end

    context 'with "SECRETS_PATH" set up' do
      include_context 'with "SECRETS_PATH" set up'

      let(:example_secret_pathname) do
        Pathname.new File.expand_path 'example_secret.txt', example_secrets_path
      end

      let(:example_nested_secret_pathname) do
        nested = File.join 'nested_folder', 'nested_folder', 'nested_example_secret.txt'
        Pathname.new File.expand_path nested, example_secrets_path
      end
      
      it 'includes files directly in the configured secrets path' do
        expect(subject.secret_mounted_file_paths)
          .to include example_secret_pathname
      end
      
      it 'includes files in subdirectories in the configured secrets path' do
        expect(subject.secret_mounted_file_paths)
          .to include example_nested_secret_pathname
      end
    end
  end

  describe '#perform!' do
    it 'does not change the env variables' do
      expect { subject.perform! }.not_to change { ENV.keys.count }
    end

    context 'with "SECRETS_PATH" set up' do
      include_context 'with "SECRETS_PATH" set up'
      it 'loads content from files in the secrets directory' do
        expect { subject.perform! }
          .to change { ENV['EXAMPLE_SECRET'] }.from(nil).to 'SAMPLE_VALUE'
      end

      it 'loads content from files inside directories on the secrets directory' do
        expect { subject.perform! }
          .to change { ENV['NESTED_EXAMPLE_SECRET'] }
          .from(nil)
          .to 'SAMPLE_VALUE'
      end
    end
  end
end
