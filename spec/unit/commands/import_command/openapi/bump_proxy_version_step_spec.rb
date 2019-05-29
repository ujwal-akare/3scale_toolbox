RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::BumpProxyVersionStep do
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:openapi_context) { { target: service } }

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :each do
      allow(service).to receive(:id).and_return(1000)
    end

    it 'service update proxy method called' do
      expect(service).to receive(:update_proxy).with(hash_including(service_id: 1000))
                                               .and_return({})
      subject
    end
  end
end
