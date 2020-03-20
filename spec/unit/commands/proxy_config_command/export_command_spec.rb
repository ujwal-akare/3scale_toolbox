RSpec.describe ThreeScaleToolbox::Commands::ProxyConfigCommand::Export::ExportSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client) }
    let(:proxy_config_env) { 'production' }
    let(:remote_name) { 'myremote' }
    let(:arguments) { { remote: remote_name } }
    let(:options) { { environment: proxy_config_env } }
    let(:svc_a_attrs) { { 'id' => '1' } }
    let(:svc_b_attrs) { { 'id' => '2' } }
    let(:content_a) { { 'some_attr' => 'A' } }
    let(:content_b) { { 'some_attr' => 'B' } }
    let(:proxy_conf_a) { { 'id' => '1', 'version' => 23, 'content' => content_a } }
    let(:proxy_conf_b) { { 'id' => '2', 'version' => 13, 'content' => content_b } }
    let(:service_list_attrs) { [svc_a_attrs, svc_b_attrs] }
    let(:pretty_printed_configs) { JSON.pretty_generate('services' => [content_a, content_b]) + "\n" }

    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:proxy_config_class) { class_double(ThreeScaleToolbox::Entities::ProxyConfig).as_stubbed_const }
    let(:proxy_config) { instance_double(ThreeScaleToolbox::Entities::ProxyConfig) }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
      expect(remote).to receive(:list_services).and_return(service_list_attrs)
      expect(remote).to receive(:proxy_config_latest).with(1, proxy_config_env).and_return(proxy_conf_a)
      expect(remote).to receive(:proxy_config_latest).with(2, proxy_config_env).and_return(proxy_conf_b)
    end

    it 'exports proxy config for all products' do
      expect { subject.run }.to output(pretty_printed_configs).to_stdout
    end
  end
end
