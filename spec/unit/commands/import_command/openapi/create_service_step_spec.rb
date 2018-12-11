RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateServiceStep do
  let(:service) { double('service') }
  let(:api_spec) { double('service') }
  let(:service_id) { '100' }
  let(:service) { ThreeScaleToolbox::Entities::Service.new(id: service_id, remote: nil) }
  let(:threescale_client) { double('threescale_client') }
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:openapi_context) do
    {
      service: service,
      api_spec: api_spec,
      threescale_client: threescale_client
    }
  end
  let(:expected_service_attrs) do
    {
      'name' => title,
      'description' => description
    }
  end

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :each do
      allow(api_spec).to receive(:title).and_return(title)
      allow(api_spec).to receive(:description).and_return(description)
    end

    it 'expected remote' do
      expect(ThreeScaleToolbox::Entities::Service).to receive(:create)
        .with(hash_including(remote: threescale_client)).and_return(service)
      expect { subject }.to output(/Created service id: #{service_id}/).to_stdout
    end

    it 'expected service attributes' do
      expect(ThreeScaleToolbox::Entities::Service).to receive(:create)
        .with(hash_including(service: expected_service_attrs)).and_return(service)
      expect { subject }.to output(/Created service id: #{service_id}/).to_stdout
    end

    it 'expected system_name' do
      expect(ThreeScaleToolbox::Entities::Service).to receive(:create)
        .with(hash_including(system_name: 'some_title')).and_return(service)
      expect { subject }.to output(/Created service id: #{service_id}/).to_stdout
    end
  end
end
