require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::ProxyConfigCommand::List::ListSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:remote_name) { "myremote" }
    let(:service_ref) { "6" }
    let(:proxy_config_env) { "production" }

    let(:options) { {} }
    let(:arguments) { {remote: remote_name, service: service_ref, environment: proxy_config_env} }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    it 'when service is not found an error is raised' do
      expect(service_class).to receive(:find).and_return(nil)
      expect { subject.run }.to raise_error(ThreeScaleToolbox::Error)
    end

    it 'when no proxy_configs are present the result header is printed' do
      expect(service_class).to receive(:find).and_return(service)
      expect(service).to receive(:proxy_configs).with(proxy_config_env).and_return([])
      expect { subject.run }.to output(/.*ID\tVERSION\tENVIRONMENT.*/).to_stdout
    end

    context 'when proxy_config list is returned' do
      let(:proxy_config_1_attrs) { {"id" => 1, "environment" => "production", "version" => "1"} }
      let(:proxy_config_2_attrs) { {"id" => 2, "environment" => "production", "version" => "2"} }
      let(:proxy_config_3_attrs) { {"id" => 3, "environment" => "production", "version" => "3"} }
      let(:proxy_config_1) { instance_double('ThreeScaleToolbox::Entities::ProxyConfig') }
      let(:proxy_config_2) { instance_double('ThreeScaleToolbox::Entities::ProxyConfig') }
      let(:proxy_config_3) { instance_double('ThreeScaleToolbox::Entities::ProxyConfig') }
      let (:proxy_config_arr) { [proxy_config_1, proxy_config_2, proxy_config_3] }

      before :example do
        expect(service_class).to receive(:find).and_return(service)
        expect(service).to receive(:proxy_configs).with(proxy_config_env).and_return(proxy_config_arr)
        expect(proxy_config_1).to receive(:attrs).and_return(proxy_config_1_attrs)
        expect(proxy_config_2).to receive(:attrs).and_return(proxy_config_2_attrs)
        expect(proxy_config_3).to receive(:attrs).and_return(proxy_config_3_attrs)
      end

      it "shows proxy_config_1" do
        expect { subject.run }.to output(/1.*production/).to_stdout
      end

      it "shows proxy_config_2" do
        expect { subject.run }.to output(/1.*production/).to_stdout
      end

      it "shows proxy_config_3" do
        expect { subject.run }.to output(/2.*production/).to_stdout
      end
    end
  end
end