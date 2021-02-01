RSpec.describe 'ProxyConfig Show command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  include_context :proxy_config_real_cleanup

  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  let(:service_ref) { "svc_#{random_lowercase_name}" }
  let(:environment_sandbox) { "sandbox" }
  let(:environment_prod) { "production" }

  context "With the specified service existing" do
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

    before :example do
      pc = ThreeScaleToolbox::Entities::ProxyConfig::find(service: service, environment: environment_sandbox, version: 1)
      expect(pc).not_to be_nil

      pc.promote(to: "production")

      ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: { friendly_name: "mymetric_#{random_lowercase_name}",
                                                                            unit: "1",
                                                                          }
                                                )
      api3scale_client.proxy_deploy service.id

      pc = ThreeScaleToolbox::Entities::ProxyConfig::find(service: service, environment: environment_sandbox, version: 2)
      expect(pc).not_to be_nil

      pc.promote(to: "production")

      ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: { friendly_name: "mymetric_#{random_lowercase_name}",
                                                                            unit: "1",
                                                                          }
                                                )
      api3scale_client.proxy_deploy service.id
    end

    context "and with environment set to sandbox" do
      let(:environment) { environment_sandbox}

      context "without specifying a config-version" do
        let(:expected_config_version) { 3 }
        let(:command_line_str) { "proxy-config show #{remote} #{service.id} #{environment}" }
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
        let(:command_line_str) { "proxy-config show #{remote} #{service.id} #{environment} --config-version #{config_version}" }

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
        let(:command_line_str) { "proxy-config show #{remote} #{service.id} #{environment}" }

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
        let(:command_line_str) { "proxy-config show #{remote} #{service.id} #{environment} --config-version #{config_version}" }

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
