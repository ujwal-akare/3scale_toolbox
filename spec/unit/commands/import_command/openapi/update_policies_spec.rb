RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdatePoliciesStep do
  let(:api_spec) do
    instance_double(ThreeScaleToolbox::OpenAPI::OAS3, 'api_spec')
  end
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service, 'service') }
  let(:default_credentials_userkey) { '12345' }
  let(:override_private_basepath) { nil }
  let(:override_public_basepath) { nil }
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
      default_credentials_userkey: default_credentials_userkey,
      override_private_basepath: override_private_basepath,
      override_public_basepath: override_public_basepath
    }
  end
  let(:security) { nil }
  let(:base_path) { '/v1' }

  context '#call' do
    before :each do
      allow(api_spec).to receive(:security).and_return(security)
      allow(api_spec).to receive(:base_path).and_return(base_path)
      allow(service).to receive(:policies).and_return(available_policies)
    end
    subject { described_class.new(openapi_context).call }

    context 'no sec requirements' do
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
      let(:security) { { id: 'apikey', type: 'apiKey', name: 'api_key', in_f: 'query' } }

      it 'policy chain not updated' do
        # doubles are strict by default.
        # if service double receives `update_policies` call, test will fail
        subject
      end
    end

    context 'oauth2 sec requirement' do
      let(:scopes) { ['writes:admin'] }
      let(:security) { { id: 'oidc', type: 'oauth2', flow: :implicit_flow_enabled, scopes: scopes } }
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

      context 'empty scope array' do
        let(:scopes) { [] }

        it 'policy chain not updated' do
          # doubles are strict by default.
          # if service double receives `update_policies` call, test will fail
          subject
        end
      end
    end

    context 'same private and public base paths' do
      let(:base_path) { '/v1' }

      it 'url_rewritting policy not added' do
        expect(service).to receive(:update_policies).with(excluding_policies('url_rewriting'))
        subject
      end

      context 'private and public base path overriden' do
        let(:base_path) { '/v2' }
        let(:override_private_basepath) { '/v1' }
        let(:override_public_basepath) { '/v1' }

        it 'url_rewritting policy not added' do
          expect(service).to receive(:update_policies).with(excluding_policies('url_rewriting'))
          subject
        end
      end
    end

    context 'diff private and public base paths' do
      let(:override_public_basepath) { '/v1' }
      let(:base_path) { '/pets' }
      let(:regex) { '^/v1' }
      let(:replace) { '/pets' }
      let(:url_rewritting_policy) do
        {
          name: 'url_rewriting',
          version: 'builtin',
          configuration: {
            commands: [
              {
                op: 'sub',
                regex: regex,
                replace: replace
              }
            ]
          },
          enabled: true
        }
      end

      it 'url_rewritting added' do
        expect(service).to receive(:update_policies)
          .with(hash_including('policies_config' => array_including(url_rewritting_policy)))
        subject
      end

      context 'regex has / at the end' do
        let(:override_public_basepath) { '/v1/' }
        let(:base_path) { '/cats' }
        let(:regex) { '^/v1/' }
        let(:replace) { '/cats/' }

        it 'replace ends with /' do
          expect(service).to receive(:update_policies)
            .with(hash_including('policies_config' => array_including(url_rewritting_policy)))
          subject
        end
      end

      context 'update existing policy' do
        let(:available_policies) do
          [
            {
              'name' => 'url_rewriting',
              'version' => 'builtin',
              'configuration' => {
                'commands' => [
                  {
                    'op' => 'sub',
                    'regex' => '^/some/path',
                    'replace' => 'other/path'
                  }
                ]
              },
              'enabled' => true
            }
          ]
        end

        it 'url_rewritting updated' do
          expect(service).to receive(:update_policies)
            .with(hash_including('policies_config' => array_including(url_rewritting_policy)))
          subject
        end
      end
    end
  end
end
