RSpec.shared_examples 'oidc is updated with required flow' do
  it 'oidc is updated with required flow' do
    expect(service).to receive(:update_oidc)
      .with(hash_including(standard_flow_enabled: expected_standard_flow,
                           implicit_flow_enabled: expected_implicit_flow,
                           service_accounts_enabled: expected_service_accounts,
                           direct_access_grants_enabled: expected_direct_access_grants))
      .and_return({})
    subject
  end
end

RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdateServiceOidcConfStep do
  let(:api_spec) do
    instance_double(ThreeScaleToolbox::OpenAPI::OAS3, 'api_spec')
  end
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service, 'service') }
  let(:logger) { Logger.new(File::NULL) }
  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec,
      logger: logger,
    }
  end

  context '#call' do
    subject { described_class.new(openapi_context).call }

    before :each do
      allow(api_spec).to receive(:security).and_return(security)
    end

    context 'no sec requirements' do
      let(:security) { nil }

      it 'policy chain not updated' do
        # doubles are strict by default.
        # if service double receives `update_policies` call, test will fail
        subject
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
      let(:expected_standard_flow) { false }
      let(:expected_implicit_flow) { false }
      let(:expected_service_accounts) { false }
      let(:expected_direct_access_grants) { false }
      let(:security) { { id: 'oidc', type: 'oauth2', flow: flow } }

      context 'flow implicit' do
        let(:flow) { :implicit_flow_enabled }
        let(:expected_implicit_flow) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'flow password' do
        let(:flow) { :direct_access_grants_enabled }
        let(:expected_direct_access_grants) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'flow application' do
        let(:flow) { :service_accounts_enabled }
        let(:expected_service_accounts) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'flow accessCode' do
        let(:flow) { :standard_flow_enabled }
        let(:expected_standard_flow) { true }

        it_behaves_like 'oidc is updated with required flow'
      end
    end
  end
end
