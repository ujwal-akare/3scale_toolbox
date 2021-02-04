RSpec.describe 'ProxyConfig Promote command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  include_context :proxy_config_real_cleanup

  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  let(:service_ref) { "svc_#{random_lowercase_name}" }
  let(:environment_sandbox) { "sandbox" }
  let(:environment_prod) { "production" }

  context "Trying to promote a Proxy configuration version" do
    let(:service) do
      svc = ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: {"name" => service_ref})
      backend = ThreeScaleToolbox::Entities::Backend::create(remote: api3scale_client,
                                                             attrs: { 'name' => "mybackend_#{random_lowercase_name}",
                                                                      'private_endpoint' => 'https://example.com'
                                                                    }
                                                            )
      ThreeScaleToolbox::Entities::BackendUsage::create(product: svc, attrs: { 'backend_api_id' => backend.id,
                                                                               'path' => '/v3'
                                                                              }
                                                       )
      api3scale_client.proxy_deploy svc.id

      svc
    end
    let(:command_line_str) { "proxy-config promote #{remote} #{service.id}" }

    context "That hasn't been promoted" do
      it "promotes the configuration version into production" do
        expect(subject).to eq(0)

        pc = ThreeScaleToolbox::Entities::ProxyConfig::find_latest(service: service, environment: environment_prod)
        expect(pc).not_to be_nil
        expect(pc.version).to eq(1)
      end
    end

    context "That has already been promoted" do
      before :example do
        pc = ThreeScaleToolbox::Entities::ProxyConfig::find(service: service, environment: environment_sandbox, version: 1)
        expect(pc).not_to be_nil

        pc.promote(to: environment_prod)
        
        pc = ThreeScaleToolbox::Entities::ProxyConfig::find(service: service, environment: environment_prod, version: 1)
        expect(pc).not_to be_nil
      end

      it "results in not being promoted and a warning shown" do
        expect(subject).to eq(0)

        pc = ThreeScaleToolbox::Entities::ProxyConfig::find_latest(service: service, environment: environment_prod)
        expect(pc).not_to be_nil
        expect(pc.version).to eq(1)
      end
    end
  end
end
