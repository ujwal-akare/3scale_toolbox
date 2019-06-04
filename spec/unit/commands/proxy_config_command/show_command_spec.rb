RSpec.describe ThreeScaleToolbox::Commands::ProxyConfigCommand::Show::ShowSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:proxy_config_class) { class_double(ThreeScaleToolbox::Entities::ProxyConfig).as_stubbed_const }
    let(:proxy_config) { instance_double(ThreeScaleToolbox::Entities::ProxyConfig) }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
    let(:service_ref) { 3 }
    let(:proxy_config_env) { "production" }
    let(:remote_name) { "myremote" }
    let(:arguments) { {remote: remote_name, service: service_ref , environment: proxy_config_env} }
    let(:options) { {} }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    it 'when service is not found an error is raised' do
      expect(service_class).to receive(:find).and_return(nil)
      expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
    end

    context "when proxy_config version is not specified" do
      before :example do
        expect(service_class).to receive(:find).and_return(service)
      end
      context "and the proxy_config is not found" do
        it "an error is raised" do
          expect(service).to receive(:id).and_return(service_ref)
          expect(proxy_config_class).to receive(:find_latest).and_return(nil)
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
       end
      end

      context "and the proxy_config is found" do
        let(:proxy_config_attrs) { {"id" => 5, "environment" => proxy_config_env, "version" => 5} }
        let(:pretty_printed_config_attrs) { JSON.pretty_generate(proxy_config_attrs) + "\n" }
        it 'the proxy_config content is shown' do
          expect(proxy_config).to receive(:attrs).and_return(proxy_config_attrs)
          expect(proxy_config_class).to receive(:find_latest).with(service: service, environment: proxy_config_env).and_return(proxy_config)
          expect { subject.run }.to output(pretty_printed_config_attrs).to_stdout
        end
      end
    end

    context "when proxy_config version is specified" do
      let(:proxy_config_version) { 9 }
      let(:options)  { { :'config-version' => proxy_config_version } }

      before :example do
        expect(service_class).to receive(:find).and_return(service)
      end

      context "and the proxy_config is not found" do
        it "an error is raised" do
          expect(service).to receive(:id).and_return(service_ref)
          expect(proxy_config_class).to receive(:find).and_return(nil)
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
        end
      end

      context "and the proxy_config is found" do
        let(:proxy_config_attrs) { {"id" => 5, "environment" => proxy_config_env, "version" => proxy_config_version } }
        let(:pretty_printed_config_attrs) { JSON.pretty_generate(proxy_config_attrs) + "\n" }
        it 'the proxy_config content is shown' do
          expect(proxy_config).to receive(:attrs).and_return(proxy_config_attrs)
          expect(proxy_config_class).to receive(:find).with(service: service, environment: proxy_config_env, version: proxy_config_version).and_return(proxy_config)
          expect { subject.run }.to output(pretty_printed_config_attrs).to_stdout
        end
      end
    end
  end
end
