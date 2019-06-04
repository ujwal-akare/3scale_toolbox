RSpec.describe ThreeScaleToolbox::Commands::ProxyConfigCommand::Promote::PromoteSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:proxy_config_class) { class_double(ThreeScaleToolbox::Entities::ProxyConfig).as_stubbed_const }
    let(:proxy_config) { instance_double(ThreeScaleToolbox::Entities::ProxyConfig) }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
    let(:service_ref) { 3 }
    let(:proxy_config_env) { "sandbox" }
    let(:remote_name) { "myremote" }
    let(:arguments) { {remote: remote_name, service: service_ref} }
    let(:options) { {} }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    it 'when service is not found an error is raised' do
      expect(service_class).to receive(:find).and_return(nil)
      expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
    end

    context "when proxy_config is not found" do
      it "an error is raised" do
        expect(service).to receive(:id).and_return(service_ref)
        expect(service_class).to receive(:find).and_return(service)
        expect(proxy_config_class).to receive(:find_latest).and_return(nil)
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
      end
    end

    context "when proxy_config is found" do
      let(:promote_to_env) { "production" }
      let(:proxy_config_attrs) { {"id" => 5, "environment" => proxy_config_env, "version" => 6} }
      let(:proxy_config_res) { {"id" => 5, "environment" =>promote_to_env, "version" => 6} }

      before :example do
        expect(service_class).to receive(:find).and_return(service)
        expect(proxy_config_class).to receive(:find_latest).with(service: service, environment: proxy_config_env).and_return(proxy_config)
      end
      it 'the proxy_config content is shown' do
        expect(proxy_config).to receive(:promote).with(to: promote_to_env).and_return(proxy_config_res)
        expect { subject.run}.to output("Proxy Configuration promoted to '#{promote_to_env}'\n").to_stdout
      end

      context "and the proxy_config cannot be promoted" do
        it 'an error is raised' do
          expect(proxy_config).to receive(:promote).with(to: promote_to_env).and_raise(ThreeScaleToolbox::ThreeScaleApiError)
          expect { subject.run}.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end
    end
  end
end
