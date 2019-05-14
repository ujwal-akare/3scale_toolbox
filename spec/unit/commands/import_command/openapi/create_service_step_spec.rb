RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateServiceStep do
  let(:api_spec) { instance_double('ThreeScaleToolbox::ImportCommand::OpenAPI::ThreeScaleApiSpec') }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_id) { '100' }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
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
  let(:expected_settings) do
    {
      'name' => title,
      'description' => description,
      'backend_version' => 'oidc'
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

      before :example do
        expect(service_class).to receive(:find_by_system_name)
          .with(remote: threescale_client, system_name: openapi_context[:target_system_name])
          .and_return(service)
        expect(service).to receive(:id).and_return(service_id)
      end

      it 'service is updated' do
        expect(service).to receive(:update).with(expected_settings)
        expect { subject }.to output(/Updated service id: #{service_id}/).to_stdout
      end
    end

    context 'when service does not exist' do
      before :example do
        expect(service_class).to receive(:find_by_system_name)
          .with(remote: threescale_client, system_name: openapi_context[:target_system_name])
          .and_return(nil)
      end

      it 'service is created' do
        expect(service_class).to receive(:create).with(hash_including(service: expected_settings))
                                                 .and_return(service)
        expect(service).to receive(:id).and_return(service_id)
        expect { subject }.to output(/Created service id: #{service_id}/).to_stdout
      end
    end
  end
end
