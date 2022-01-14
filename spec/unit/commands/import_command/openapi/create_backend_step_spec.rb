RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateBackendStep do
  let(:api_spec) { instance_double(ThreeScaleToolbox::OpenAPI::OAS3, 'api_spec') }
  let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
  let(:backend_id) { '100' }
  let(:backend) { instance_double('ThreeScaleToolbox::Entities::backend') }
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:system_name) { 'some_system_name' }
  let(:logger) { Logger.new(File::NULL) }
  let(:openapi_context) do
    {
      target: backend,
      api_spec: api_spec,
      threescale_client: threescale_client,
      target_system_name: system_name,
      logger: logger,
    }
  end

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :example do
      allow(backend).to receive(:system_name).and_return(system_name)
      allow(backend).to receive(:name).and_return(title)
      allow(backend).to receive(:id).and_return(backend_id)
      allow(backend).to receive(:private_endpoint).and_return('http://example.com')
      allow(api_spec).to receive(:title).and_return(title)
      allow(api_spec).to receive(:description).and_return(description)
      allow(api_spec).to receive(:host).and_return('example.com')
      allow(api_spec).to receive(:scheme).and_return('http')
    end

    context 'when backend exists' do
      let(:expected_update_attrs) do
        {
          'name' => title,
          'description' => description,
          'private_endpoint' => 'http://example.com',
        }
      end
      before :example do
        expect(backend_class).to receive(:find_by_system_name)
          .with(remote: threescale_client, system_name: openapi_context[:target_system_name])
          .and_return(backend)
      end

      it 'backend is updated' do
        expect(backend).to receive(:update).with(expected_update_attrs)
        subject
      end
    end

    context 'when backend does not exist' do
      let(:expected_create_attrs) do
        {
          'name' => title,
          'system_name' => system_name,
          'description' => description,
          'private_endpoint' => 'http://example.com',
        }
      end

      before :example do
        expect(backend_class).to receive(:find_by_system_name)
          .with(remote: threescale_client, system_name: openapi_context[:target_system_name])
          .and_return(nil)
      end

      it 'backend is created' do
        expect(backend_class).to receive(:create).with(hash_including(attrs: expected_create_attrs))
                                                 .and_return(backend)
        expect(backend).to receive(:id).and_return(backend_id)
        subject
      end
    end
  end
end
