RSpec.describe ThreeScaleToolbox::Commands::ProxyConfigCommand::Promote::PromoteSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:proxy_config_class) { class_double(ThreeScaleToolbox::Entities::ProxyConfig).as_stubbed_const }
    let(:proxy_config_from) { instance_double(ThreeScaleToolbox::Entities::ProxyConfig) }
    let(:proxy_config_to) { instance_double(ThreeScaleToolbox::Entities::ProxyConfig) }
    let(:proxy_config_env_from) { "sandbox" }
    let(:proxy_config_env_to) { "production" }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
    let(:service_ref) { 3 }
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

    context "when proxy_config sandbox is not found" do
      it "an error is raised" do
        expect(service).to receive(:id).and_return(service_ref)
        expect(service_class).to receive(:find).and_return(service)
        expect(proxy_config_class).to receive(:find_latest).and_return(nil).twice
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
      end
    end

    context "when proxy_config sandbox is found" do
      let(:proxy_config_version_to) { 1 }
      let(:proxy_config_res) { {"id" => 5, "environment" => proxy_config_env_to, "version" => proxy_config_version_to} }

      before :example do
        expect(service_class).to receive(:find).and_return(service)
      end

      context "and has never been promoted to production" do
        let(:proxy_config_version_from) { 1 }

        it "the proxy_config is promoted" do
          expect(proxy_config_from).to receive(:version).and_return(proxy_config_version_from)
          expect(proxy_config_class).to receive(:find_latest).with(service: service, environment: proxy_config_env_to).and_return(nil)
          expect(proxy_config_class).to receive(:find_latest).with(service: service, environment: proxy_config_env_from).and_return(proxy_config_from)
          expect(proxy_config_from).to receive(:promote).with(to: proxy_config_env_to).and_return(proxy_config_res)
          expect { subject.run }.to output("Proxy Configuration version #{proxy_config_version_from} promoted to '#{proxy_config_env_to}'\n").to_stdout
        end
      end

      context "and has at least once time been promoted to production" do

        before :example do
          expect(proxy_config_from).to receive(:version).and_return(proxy_config_version_from).twice
          expect(proxy_config_to).to receive(:version).and_return(proxy_config_version_to)
          expect(proxy_config_class).to receive(:find_latest).with(service: service, environment: proxy_config_env_to).and_return(proxy_config_to)
          expect(proxy_config_class).to receive(:find_latest).with(service: service, environment: proxy_config_env_from).and_return(proxy_config_from)
        end

        context "and the currently existing promoted version is the same as the version to promote" do
          let(:proxy_config_version_from) { 1 }
  
          it "the proxy_config is not promoted" do
            expect { subject.run }.to output(/warning/).to_stderr
          end
        end
  
        context "and the currently existing promoted version is not the same as the version to promote" do
          let(:proxy_config_version_from) { 2 }
  
          it "the proxy_config is promoted" do
            expect(proxy_config_from).to receive(:promote).with(to: proxy_config_env_to).and_return(proxy_config_res)
            expect { subject.run}.to output("Proxy Configuration version #{proxy_config_version_from} promoted to '#{proxy_config_env_to}'\n").to_stdout
          end
        end
      end
    end
  end
end
