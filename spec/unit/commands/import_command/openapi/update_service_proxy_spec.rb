RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdateServiceProxyStep do
  let(:api_spec) { instance_double('ThreeScaleToolbox::ImportCommand::OpenAPI::ThreeScaleApiSpec') }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:schemes) { [] }
  let(:host) { 'example.com' }
  let(:oidc_issuer_endpoint) { 'https://sso.example.com' }
  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec,
      oidc_issuer_endpoint: oidc_issuer_endpoint
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

    context 'no sec requirements' do
      let(:security) { nil }

      it 'updates proxy' do
        expect(service).to receive(:update_proxy)
          .with(hash_including(api_backend: 'https://example.com')).and_return({})
        subject
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
                    api_backend: 'https://example.com',
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
                    api_backend: 'https://example.com',
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
                  api_backend: 'https://example.com',
                  credentials_location: 'headers',
                  oidc_issuer_endpoint: oidc_issuer_endpoint
                )).and_return({})
        subject
      end
    end
  end
end
