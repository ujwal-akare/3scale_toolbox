RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdatePoliciesStep do
  let(:api_spec) { double('api_spec') }
  let(:service) { double('service') }
  let(:default_credentials_userkey) { nil }
  let(:available_policies) do
    [
      {
        'name' => 'apicast',
        'version' => 'builtin',
        'configuration' => {},
        'enabled' => true
      }
    ]
  end
  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec,
      default_credentials_userkey: default_credentials_userkey
    }
  end

  context '#call' do
    before :each do
      allow(api_spec).to receive(:security).and_return(security)
      allow(service).to receive(:policies).and_return(available_policies)
    end
    subject { described_class.new(openapi_context).call }

    context 'no sec requirements' do
      let(:security) { nil }
      let(:default_credentials_userkey) { '12345' }
      let(:expected_anonymous_policy_settings) do
        {
          name: 'default_credentials',
          version: 'builtin',
          configuration: { auth_type: 'user_key', user_key: default_credentials_userkey },
          enabled: true
        }
      end

      it 'anonymous policy is created' do
        expect(service).to receive(:update_policies)
          .with(hash_including('policies_config' => array_including(expected_anonymous_policy_settings)))
          .and_return({})
        subject
      end

      context 'no default_credentials_userkey provided' do
        let(:default_credentials_userkey) { nil }
        it 'raises error' do
          expect { subject }.to raise_error(ThreeScaleToolbox::Error, /User key/)
        end
      end

      context 'anonymous policy already in chain' do
        let(:available_policies) do
          [
            {
              'name' => 'default_credentials',
              'version' => 'builtin',
              'configuration' => { 'auth_type' => 'user_key', 'user_key': default_credentials_userkey },
              'enabled' => true
            }
          ]
        end

        it 'policy chain not updated' do
          # doubles are strict by default.
          # if service double receives `update_policies` call, test will fail
          subject
        end
      end
    end

    context 'apiKey sec requirement' do
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'apikey', type: 'apiKey',
                                                            name: 'api_key', in_f: 'query')
      end

      it 'policy chain not updated' do
        # doubles are strict by default.
        # if service double receives `update_policies` call, test will fail
        subject
      end
    end

    context 'oauth2 sec requirement' do
      let(:scopes) { ['writes:admin'] }
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'oidc', type: 'oauth2',
                                                            flow: 'implicit', scopes: scopes)
      end
      let(:expected_keycloak_policy_settings) do
        {
          name: 'keycloak_role_check',
          version: 'builtin',
          configuration: {
            type: 'whitelist',
            scopes: [
              {
                realm_roles: [],
                client_roles: scopes.map { |scope| { 'name': scope } }
              }
            ]
          },
          enabled: true
        }
      end

      it 'keycloak role check policy is created' do
        expect(service).to receive(:update_policies)
          .with(hash_including('policies_config' => array_including(expected_keycloak_policy_settings)))
          .and_return({})
        subject
      end

      context 'keycloak role check policy already in chain' do
        let(:available_policies) do
          [
            {
              'name' => 'keycloak_role_check',
              'version' => 'builtin',
              'configuration' => {
                'type' => 'whitelist',
                'scopes' => [
                  {
                    'realm_roles' => [],
                    'client_roles' => scopes.map { |scope| { 'name': scope } }
                  }
                ]
              },
              'enabled' => true
            }
          ]
        end

        it 'policy chain not updated' do
          # doubles are strict by default.
          # if service double receives `update_policies` call, test will fail
          subject
        end
      end
    end
  end
end
