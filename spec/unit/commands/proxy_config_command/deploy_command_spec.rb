RSpec.describe ThreeScaleToolbox::Commands::ProxyConfigCommand::DeploySubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client) }
    let(:remote_name) { 'myremote' }
    let(:service_ref) { 'myservice' }
    let(:service_id) { 1 }
    let(:arguments) { {remote: remote_name, service_ref: service_ref} }
    let(:options) { {} }
    let(:proxy_attrs) { { 'id' => '1' } }
    let(:pretty_printed_proxy) { JSON.pretty_generate(proxy_attrs) + "\n" }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
      expect(service_class).to receive(:find).with(remote: remote, ref: service_ref).and_return(service)
      expect(service).to receive(:proxy_deploy).and_return(proxy_attrs)
    end

    it 'exports proxy config for all products' do
      expect { subject.run }.to output(pretty_printed_proxy).to_stdout
    end
  end
end
