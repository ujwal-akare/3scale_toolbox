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
  let(:api_spec) { double('api_spec') }
  let(:service) { double('service') }
  let(:openapi_context) do
    {
      target: service,
      api_spec: api_spec
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
      let(:expected_standard_flow) { false }
      let(:expected_implicit_flow) { false }
      let(:expected_service_accounts) { false }
      let(:expected_direct_access_grants) { false }
      let(:security) do
        ThreeScaleToolbox::Swagger::SecurityRequirement.new(id: 'oidc', type: 'oauth2', flow: flow)
      end

      context 'flow implicit' do
        let(:flow) { 'implicit' }
        let(:expected_implicit_flow) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'flow password' do
        let(:flow) { 'password' }
        let(:expected_direct_access_grants) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'flow application' do
        let(:flow) { 'application' }
        let(:expected_service_accounts) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'flow accessCode' do
        let(:flow) { 'accessCode' }
        let(:expected_standard_flow) { true }

        it_behaves_like 'oidc is updated with required flow'
      end

      context 'unexpected flow' do
        let(:flow) { 'invalidFlow' }

        it 'raises error' do
          expect { subject }.to raise_error(ThreeScaleToolbox::Error, /security flow/)
        end
      end
    end
  end
end
