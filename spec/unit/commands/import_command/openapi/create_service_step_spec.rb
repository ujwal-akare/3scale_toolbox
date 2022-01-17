RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateServiceStep do
  let(:api_spec) do
    instance_double(ThreeScaleToolbox::OpenAPI::OAS3, 'api_spec')
  end
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_id) { '100' }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:system_name) { 'some_system_name' }
  let(:logger) { Logger.new(File::NULL) }
  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec,
      threescale_client: threescale_client,
      target_system_name: system_name,
      logger: logger,
    }
  end
  let(:expected_settings) do
    {
      'name' => title,
      'description' => description,
      'backend_version' => 'oidc',
      'system_name' => system_name,
    }
  end

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :example do
      allow(service).to receive(:system_name).and_return(system_name)
      allow(service).to receive(:name).and_return(title)
      allow(service).to receive(:id).and_return(service_id)
      allow(api_spec).to receive(:title).and_return(title)
      allow(api_spec).to receive(:description).and_return(description)
      allow(api_spec).to receive(:service_backend_version).and_return('oidc')
    end

    context 'when service exists' do
      before :example do
        expect(service_class).to receive(:find_by_system_name)
          .with(remote: threescale_client, system_name: openapi_context[:target_system_name])
          .and_return(service)
      end

      it 'service is updated' do
        expect(service).to receive(:update).with(expected_settings)
        subject
      end

      context 'and production_public_base_url is in context' do
        let(:openapi_context) do
          {
            target: service,
            api_spec: api_spec,
            threescale_client: threescale_client,
            target_system_name: system_name,
            production_public_base_url: 'http://api.example.com',
            logger: logger,
          }
        end

        it 'service settings include deployment option' do
          expect(service).to receive(:update).with(hash_including('deployment_option' => 'self_managed'))
          subject
        end
      end

      context 'and staging_public_base_url is in context' do
        let(:openapi_context) do
          {
            target: service,
            api_spec: api_spec,
            threescale_client: threescale_client,
            target_system_name: system_name,
            staging_public_base_url: 'http://api.example.com',
            logger: logger,
          }
        end

        it 'service settings include deployment option' do
          expect(service).to receive(:update).with(hash_including('deployment_option' => 'self_managed'))
          subject
        end
      end
    end

    context 'when service does not exist' do
      before :example do
        expect(service_class).to receive(:find_by_system_name)
          .with(remote: threescale_client, system_name: openapi_context[:target_system_name])
          .and_return(nil)
      end

      it 'service is created' do
        expect(service_class).to receive(:create).with(hash_including(service_params: expected_settings))
                                                 .and_return(service)
        expect(service).to receive(:id).and_return(service_id)
        subject
      end
    end
  end
end
