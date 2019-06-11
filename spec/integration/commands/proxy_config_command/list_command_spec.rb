RSpec.describe 'ProxyConfig List command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  let(:service_ref) { "svc_#{random_lowercase_name}" }
  let(:environment_sandbox) { "sandbox" }
  let(:environment_prod) { "production" }
  
  context "With multiple existing Proxy Configurations" do
    before :example do
      svc = ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: {"name" => service_ref})

      svc.update_proxy({ "error_auth_failed" => "exampleautherrormessage1" })
      pc_sandbox_1 = ThreeScaleToolbox::Entities::ProxyConfig::find(service: svc, environment: environment_sandbox, version: 1)
      pc_sandbox_1.promote(to: "production")

      svc.update_proxy({ "error_auth_failed" => "exampleautherrormessage2" })
      pc_sandbox_2 = ThreeScaleToolbox::Entities::ProxyConfig::find(service: svc, environment: environment_sandbox, version: 2)
      pc_sandbox_2.promote(to: "production")

      svc.update_proxy({ "error_auth_failed" => "exampleautherrormessage3" })
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      res.delete if !res.nil?
    end

    context "listing sandbox Proxy configurations" do
      let (:command_line_str) { "proxy-config list #{remote} #{service_ref} #{environment_sandbox}" }

      it "lists proxy_config sandbox version 1" do
        expect { subject }.to output(/.*1.*#{environment_sandbox}.*/).to_stdout
        expect(subject).to eq(0)
      end
  
      it "lists proxy_config sandbox version 2" do
        expect { subject }.to output(/.*2.*#{environment_sandbox}.*/).to_stdout
        expect(subject).to eq(0)
      end

      it "lists proxy_config sandbox version 3" do
        expect { subject }.to output(/.*3.*#{environment_sandbox}.*/).to_stdout
        expect(subject).to eq(0)
      end
    end

    context "listing production Proxy configurations" do
      let (:command_line_str) { "proxy-config list #{remote} #{service_ref} #{environment_prod}" }

      it "lists proxy_config production version 1" do
        expect { subject }.to output(/.*1.*#{environment_prod}.*/).to_stdout
        expect(subject).to eq(0)
      end
  
      it "lists proxy_config production version 2" do
        expect { subject }.to output(/.*2.*#{environment_prod}.*/).to_stdout
        expect(subject).to eq(0)
      end
    end
  end
end
