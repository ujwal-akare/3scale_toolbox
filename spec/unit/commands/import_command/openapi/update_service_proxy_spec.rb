RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdateServiceProxyStep do
  let(:api_spec) { instance_double('ThreeScaleToolbox::ImportCommand::OpenAPI::ThreeScaleApiSpec') }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:schemes) { [] }
  let(:host) { nil }
  let(:security) { nil }
  let(:production_public_base_url) { nil }
  let(:staging_public_base_url) { nil }
  let(:override_private_base_url) { nil }
  let(:oidc_issuer_endpoint) { 'https://sso.example.com' }
  let(:backend_api_secret_token) { nil }
  let(:backend_api_host_header) { nil }

  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec,
      oidc_issuer_endpoint: oidc_issuer_endpoint,
      production_public_base_url: production_public_base_url,
      staging_public_base_url: staging_public_base_url,
      override_private_base_url: override_private_base_url,
      backend_api_secret_token:backend_api_secret_token,
      backend_api_host_header: backend_api_host_header,
    }
  end

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :each do
      allow(api_spec).to receive(:schemes).and_return(schemes)
      allow(api_spec).to receive(:host).and_return(host)
      allow(api_spec).to receive(:security).and_return(security)
      allow(service).to receive(:id).and_return(1000)
    end

    context 'no proxy settings' do
      it 'proxy not updated' do
        subject
      end
    end

    context 'production public base url set' do
      let(:production_public_base_url) { 'example.com' }

      it 'endpoint updated' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(endpoint: 'example.com')).and_return({})
        expect { subject }.to output.to_stdout
      end
    end

    context 'staging public base url set' do
      let(:staging_public_base_url) { 'example.com' }

      it 'sandbox_endpoint updated' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(sandbox_endpoint: 'example.com')).and_return({})
        expect { subject }.to output.to_stdout
      end
    end

    context 'api_spec host set' do
      let(:host) { 'example.com' }

      it 'api_backend updated' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(api_backend: 'https://example.com')).and_return({})
        expect { subject }.to output.to_stdout
      end
    end

    context 'backend api host header set' do
      let(:backend_api_host_header) { 'example.com'}

      it 'hostname_rewrite updated' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(hostname_rewrite: backend_api_host_header)).and_return({})
        expect { subject }.to output.to_stdout
      end
    end

    context 'backend api secret token set' do
      let(:backend_api_secret_token) { 'secret_token'}

      it 'secret_token updated' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(secret_token: backend_api_secret_token)).and_return({})
        expect { subject }.to output.to_stdout
      end
    end

    context 'private base url set' do
      let(:override_private_base_url) { 'http://echo-api.example.com' }

      it 'api_backend updated' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(api_backend: override_private_base_url)).and_return({})
        expect { subject }.to output.to_stdout
      end
    end

    context 'apiKey sec requirement' do
      let(:key_name) { 'some_name' }
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'apikey', type: 'apiKey',
                                                            name: key_name, in_f: cred_location)
      end

      context 'cred location query' do
        let(:cred_location) { 'query' }

        it 'updates proxy' do
          expect(service).to receive(:update_proxy)
            .with(hash_including(
                    credentials_location: 'query',
                    auth_user_key: key_name
                  )).and_return({})
          subject
        end
      end

      context 'cred location header' do
        let(:cred_location) { 'header' }

        it 'updates proxy' do
          expect(service).to receive(:update_proxy)
            .with(hash_including(
                    credentials_location: 'headers',
                    auth_user_key: key_name
                  )).and_return({})
          subject
        end
      end

      context 'unexpected cred location' do
        let(:cred_location) { 'unexpected_cred_location' }

        it 'raises error' do
          expect { subject }.to raise_error(ThreeScaleToolbox::Error, /in_f field/)
        end
      end
    end

    context 'oauth2 sec requirement' do
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'oidc', type: 'oauth2',
                                                            flow: 'implicit')
      end

      it 'updates proxy' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(
                  credentials_location: 'headers',
                  oidc_issuer_endpoint: oidc_issuer_endpoint
                )).and_return({})
        subject
      end
    end
  end
end
