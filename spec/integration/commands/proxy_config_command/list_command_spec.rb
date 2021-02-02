RSpec.describe 'ProxyConfig List command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  include_context :proxy_config_real_cleanup

  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  let(:service_ref) { "svc_#{random_lowercase_name}" }
  let(:environment_sandbox) { "sandbox" }
  let(:environment_prod) { "production" }
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
  let(:hits_id) { service.hits.fetch('id') }

  context "With multiple existing Proxy Configurations" do
    before :example do
      pc = ThreeScaleToolbox::Entities::ProxyConfig::find(service: service, environment: environment_sandbox, version: 1)
      expect(pc).not_to be_nil

      pc.promote(to: "production")

      service.create_mapping_rule('pattern' => "/pets/#{random_lowercase_name}$",
                                'http_method' => 'GET',
                                'delta' => 1,
                                'metric_id' => hits_id
                               )

      api3scale_client.proxy_deploy service.id

      pc = ThreeScaleToolbox::Entities::ProxyConfig::find(service: service, environment: environment_sandbox, version: 2)
      expect(pc).not_to be_nil

      pc.promote(to: "production")

      service.create_mapping_rule('pattern' => "/pets/#{random_lowercase_name}$",
                                'http_method' => 'GET',
                                'delta' => 1,
                                'metric_id' => hits_id
                               )
      api3scale_client.proxy_deploy service.id
    end

    context "listing sandbox Proxy configurations" do
      let (:command_line_str) { "proxy-config list #{remote} #{service.id} #{environment_sandbox}" }

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
      let (:command_line_str) { "proxy-config list #{remote} #{service.id} #{environment_prod}" }

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
