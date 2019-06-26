RSpec.describe 'ProxyConfig Show command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  let(:service_ref) { "svc_#{random_lowercase_name}" }
  let(:environment_sandbox) { "sandbox" }
  let(:environment_prod) { "production" }

  context "With the specified service existing" do
    before :example do
      svc = ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: {"name" => service_ref})

      svc.update_proxy({ "error_auth_failed" => "exampleautherrormessage1" })
      pc_sandbox_1 = nil
      Helpers.wait do
        pc_sandbox_1 = ThreeScaleToolbox::Entities::ProxyConfig::find(service: svc, environment: environment_sandbox, version: 1)
        !pc_sandbox_1.nil?
      end
      pc_sandbox_1.promote(to: "production")

      svc.update_proxy({ "error_auth_failed" => "exampleautherrormessage2" })
      pc_sandbox_2 = nil
      Helpers.wait do
        pc_sandbox_2 = ThreeScaleToolbox::Entities::ProxyConfig::find(service: svc, environment: environment_sandbox, version: 2)
        !pc_sandbox_2.nil?
      end
      pc_sandbox_2.promote(to: "production")

      svc.update_proxy({ "error_auth_failed" => "exampleautherrormessage3" })
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      res.delete if !res.nil?
    end

    context "and with environment set to sandbox" do
      let(:environment) { environment_sandbox}

      context "without specifying a config-version" do
        let(:expected_config_version) { 3 }
        let(:command_line_str) { "proxy-config show #{remote} #{service_ref} #{environment}" }
        it "returns the latest available version" do
          expect { subject }.to output(/"version": #{expected_config_version}/).to_stdout
          expect(subject).to eq(0)
        end
        it "returns the specified environment" do
          expect { subject }.to output(/"environment": "#{environment}"/).to_stdout
          expect(subject).to eq(0)
        end
      end

      context "specifying a config-version" do
        let(:config_version) { 2 }
        let(:expected_config_version) { config_version }
        let(:command_line_str) { "proxy-config show #{remote} #{service_ref} #{environment} --config-version #{config_version}" }

        it "returns the specified version" do
          expect { subject }.to output(/"version": #{expected_config_version}/).to_stdout
          expect(subject).to eq(0)
        end
        it "returns the specified environment" do
          expect { subject }.to output(/"environment": "#{environment}"/).to_stdout
          expect(subject).to eq(0)
        end
      end
    end

    context "and with environment set to production" do
      let(:environment) { environment_prod}

      context "without specifying a config-version" do
        let(:expected_config_version) { 2 }
        let(:command_line_str) { "proxy-config show #{remote} #{service_ref} #{environment}" }

        it "returns the latest available version" do
          expect { subject }.to output(/"version": #{expected_config_version}/).to_stdout
          expect(subject).to eq(0)
        end
        it "returns the specified environment" do
          expect { subject }.to output(/"environment": "#{environment}"/).to_stdout
          expect(subject).to eq(0)
        end
      end

      context "specifying a config-version" do
        let(:config_version) { 1 }
        let(:expected_config_version) { config_version }
        let(:command_line_str) { "proxy-config show #{remote} #{service_ref} #{environment} --config-version #{config_version}" }

        it "returns the specified version" do
          expect { subject }.to output(/"version": #{expected_config_version}/).to_stdout
          expect(subject).to eq(0)
        end
        it "returns the specified environment" do
          expect { subject }.to output(/"environment": "#{environment}"/).to_stdout
          expect(subject).to eq(0)
        end
      end
    end
  end
end
