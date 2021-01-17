
require 'on_container/secrets/google_cloud/fetcher'

RSpec.describe OnContainer::Secrets::GoogleCloud::Fetcher do
  around do |example|
    ClimateControl.modify GOOGLE_CLOUD_PROJECT: example_configured_project do
      example.run
    end
  end

  let(:example_configured_project) { 'foo' }
  let(:example_secret_name) { 'bar' }
  let(:example_secret_version) { 'latest' }
  let(:example_secret_key) { example_secret_name }

  subject { described_class.new example_secret_key }

  shared_context 'with a reference to a secret in another project' do
    let(:example_secret_key) { 'projects/baz/secrets/bar' }
  end

  context 'initialized with a simple secret reference' do
    describe '#project' do
      it 'returns the GCP project configured on the app' do
        expect(subject.project).to eq example_configured_project
      end
    end

    describe '#secret_name' do
      it 'returns the name of the secret' do
        expect(subject.secret_name).to eq example_secret_name
      end
    end

    describe '#secret_version' do
      it 'returns "latest"' do
        expect(subject.secret_version).to eq 'latest'
      end
    end
  end

  context 'initialized with a reference to a secret in a given project' do
    let(:example_project) { 'baz' }

    let(:example_secret_key) do
      "projects/#{example_project}/secrets/#{example_secret_name}"
    end

    describe '#project' do
      it 'returns the GCP project from the given secret reference' do
        expect(subject.project).to eq example_project
      end
    end

    describe '#secret_name' do
      it 'returns the name of the secret' do
        expect(subject.secret_name).to eq example_secret_name
      end
    end

    describe '#secret_version' do
      it 'returns "latest"' do
        expect(subject.secret_version).to eq 'latest'
      end
    end
  end

  context 'initialized with a secret version in the given secret reference' do
    let(:example_secret_version) { '1' }
    let(:example_secret_key) { "#{example_secret_name}/versions/#{example_secret_version}" }

    describe '#project' do
      it 'returns the GCP project configured on the app' do
        expect(subject.project).to eq example_configured_project
      end
    end

    describe '#secret_name' do
      it 'returns the name of the secret' do
        expect(subject.secret_name).to eq example_secret_name
      end
    end

    describe '#secret_version' do
      it 'returns the refered secret version' do
        expect(subject.secret_version).to eq example_secret_version
      end
    end
  end

  describe '#perform!' do
    let(:example_expected_data) { { 'UNO' => 'ONE' } }
    let(:example_fetched_data) { '{"UNO": "ONE"}' }

    before do
      validated_name = "projects/#{example_configured_project}/" \
                       "secrets/#{example_secret_name}/" \
                       "versions/#{example_secret_version}"
      
      service_mock = double("ServiceMock")

      
      expect(service_mock).to receive(:secret_version_path).with(
        project:        example_configured_project,
        secret:         example_secret_name,
        secret_version: example_secret_version
      ).and_return(validated_name)

      response_mock = double(
        "ResponseMock",
        payload: double("PayloadMock", data: example_fetched_data)
      )

      expect(service_mock).to receive(:access_secret_version)
        .with({name: validated_name})
        .and_return(response_mock)
      
      expect(subject).to receive(:client)
        .at_least(:once)
        .and_return(service_mock)
    end

    it 'fetches the given secret' do
      expect(subject.perform!).to include example_expected_data
    end
  end
end
