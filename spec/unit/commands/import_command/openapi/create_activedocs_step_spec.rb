RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateActiveDocsStep do
  let(:api_spec_resource) do
    {
      'host' => 'original_host.com',
      'schemes' => ['http'],
      'basePath' => '/v1',
    }
  end
  let(:api_spec) { instance_double('ThreeScaleToolbox::ImportCommand::OpenAPI::ThreeScaleApiSpec') }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:published) { true }
  let(:skip_openapi_validation) { false }
  let(:oidc_issuer_endpoint) { 'https://client_id:secret@sso.oidcissuer.com/oidc' }

  let(:openapi_context) do
    {
      api_spec_resource: api_spec_resource,
      target: service,
      api_spec: api_spec,
      threescale_client: threescale_client,
      activedocs_published: published,
      skip_openapi_validation: skip_openapi_validation,
      oidc_issuer_endpoint: oidc_issuer_endpoint
    }
  end
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:service_id) { 1 }
  let(:service_system_name) { 'some_system_name' }
  let(:new_public_base_path) { '/v2' }
  let(:activedocs_list) do
    [
      { 'id' => 1, 'system_name' => 'one' },
      { 'id' => 2, 'system_name' => service_system_name },
      { 'id' => 3, 'system_name' => 'other' }
    ]
  end
  let(:service_attrs) { { 'id' => service_id, 'system_name' => service_system_name } }
  let(:security) do
    ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'sec_id', type: 'apiKey',
                                                        name: 'sec_name')
  end
  let(:service_proxy) do
    {
      'endpoint' => 'https://example.com:443'
    }
  end

  subject { described_class.new(openapi_context) }

  context '#call' do
    before :each do
      allow(api_spec).to receive(:title).and_return(title)
      allow(api_spec).to receive(:description).and_return(description)
      allow(api_spec).to receive(:security).and_return(security)
      allow(api_spec).to receive(:public_base_path).and_return(new_public_base_path)
      allow(service).to receive(:id).and_return(service_id)
      allow(service).to receive(:attrs).and_return(service_attrs)
      allow(service).to receive(:proxy).and_return(service_proxy)
    end

    context 'creates activedocs' do
      it 'with name as title' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(name: title)).and_return({})
        subject.call
      end

      it 'with description as api_spec.description' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(description: description)).and_return({})
        subject.call
      end

      it 'with service_id' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(service_id: service_id)).and_return({})
        subject.call
      end

      it 'with system name' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(system_name: service_system_name)).and_return({})
        subject.call
      end

      it 'with body host, basePath and schemes updated' do
        oas_body = JSON.pretty_generate(
          'host' => 'example.com:443', 'schemes' => ['https'],
          'basePath' => new_public_base_path
        )
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(body: oas_body)).and_return({})
        subject.call
      end

      it 'with published flag as true' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(published: true)).and_return({})
        subject.call
      end

      it 'with skip_swagger_validations flag as false' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(skip_swagger_validations: false)).and_return({})
        subject.call
      end

      context 'context published is false' do
        let(:published) { false }
        it 'with published flag as false' do
          expect(threescale_client).to receive(:create_activedocs)
            .with(hash_including(published: false)).and_return({})
          subject.call
        end
      end

      context 'context skip_openapi_validation is true' do
        let(:skip_openapi_validation) { true }
        it 'with skip_swagger_validations flag  as true' do
          expect(threescale_client).to receive(:create_activedocs)
            .with(hash_including(skip_swagger_validations: true)).and_return({})
          subject.call
        end
      end
    end

    context 'creates activedocs and returns error' do
      before :each do
        expect(threescale_client).to receive(:create_activedocs)
          .and_return('errors' => { 'system_name' => ['some error ocurred'] })
      end

      it 'then raises error' do
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error, /some error ocurred/)
      end
    end

    context 'when activedocs already exists' do
      before :each do
        expect(threescale_client).to receive(:create_activedocs)
          .and_return('errors' => { 'system_name' => ['has already been taken'] })
        expect(threescale_client).to receive(:list_activedocs)
          .and_return(activedocs_list)
      end

      it 'then updates activedocs with expected id' do
        expect(threescale_client).to receive(:update_activedocs).with(2, anything).and_return({})
        expect { subject.call }.to output.to_stdout
      end
    end

    context 'oauth sec, flow implicit' do
      let(:api_spec_resource) do
        {
          'host' => 'original_host.com',
          'schemes' => ['http'],
          'securityDefinitions' => {
            'sec_id' => {
              'authorizationUrl' => 'https://sso.original_host.com:443/auth'
            }
          }
        }
      end
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'sec_id', type: 'oauth2',
                                                            name: 'sec_name', flow: 'implicit')
      end

      it 'body contains updated authorizationUrl' do
        oas_body = JSON.pretty_generate(
          'host' => 'example.com:443',
          'schemes' => ['https'],
          'securityDefinitions' => {
            'sec_id' => {
              'authorizationUrl' => "#{oidc_issuer_endpoint}/protocol/openid-connect/auth"
            }
          },
          'basePath' => new_public_base_path,
        )
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(body: oas_body)).and_return({})
        subject.call
      end
    end

    context 'oauth sec, flow accessCode' do
      let(:api_spec_resource) do
        {
          'host' => 'original_host.com',
          'schemes' => ['http'],
          'securityDefinitions' => {
            'sec_id' => {
              'authorizationUrl' => 'https://sso.original_host.com:443/auth'
            }
          },
          'basePath' => new_public_base_path,
        }
      end
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'sec_id', type: 'oauth2',
                                                            name: 'sec_name', flow: 'accessCode')
      end

      it 'body contains updated authorizationUrl and tokenUrl' do
        oas_body = JSON.pretty_generate(
          'host' => 'example.com:443',
          'schemes' => ['https'],
          'securityDefinitions' => {
            'sec_id' => {
              'authorizationUrl' => "#{oidc_issuer_endpoint}/protocol/openid-connect/auth",
              'tokenUrl' => "#{oidc_issuer_endpoint}/protocol/openid-connect/token"
            }
          },
          'basePath' => new_public_base_path,
        )
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(body: oas_body)).and_return({})
        subject.call
      end
    end
  end
end
