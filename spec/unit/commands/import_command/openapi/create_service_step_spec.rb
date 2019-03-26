RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateServiceStep do
  let(:api_spec) { double('api_spec') }
  let(:service_id) { '100' }
  let(:service) { ThreeScaleToolbox::Entities::Service.new(id: service_id, remote: nil) }
  let(:threescale_client) { double('threescale_client') }
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec,
      threescale_client: threescale_client,
      target_system_name: 'some_system_name'
    }
  end

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :example do
      allow(api_spec).to receive(:title).and_return(title)
      allow(api_spec).to receive(:description).and_return(description)
      allow(api_spec).to receive(:backend_version).and_return('oidc')
    end

    context 'when service exists' do
      let(:existing_services) do
        [
          { 'id' => service_id, 'system_name' => openapi_context[:target_system_name] }
        ]
      end

      let(:expected_settings) do
        {
          'name' => title,
          'description' => description,
          'backend_version' => 'oidc'
        }
      end

      before :example do
        expect(ThreeScaleToolbox::Entities::Service).to receive(:create)
          .with(hash_including(remote: threescale_client))
          .and_raise(ThreeScaleToolbox::Error, 'Service has not been saved. Errors: {"system_name"=>["has already been taken"]}')
        expect(threescale_client).to receive(:list_services).and_return(existing_services)
        expect(ThreeScaleToolbox::Entities::Service).to receive(:new)
          .with(hash_including(remote: threescale_client))
          .and_return(service)
      end

      it 'service is updated' do
        expect(service).to receive(:update_service).with(expected_settings)
        expect { subject }.to output(/Updated service id: #{service_id}/).to_stdout
      end
    end

    context 'when service does not exist' do
      before :example do
        expect(ThreeScaleToolbox::Entities::Service).to receive(:create)
          .with(hash_including(remote: threescale_client))
          .and_return(service)
      end

      it 'service is created' do
        expect { subject }.to output(/Created service id: #{service_id}/).to_stdout
      end
    end
  end
end
