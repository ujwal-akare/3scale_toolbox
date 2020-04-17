RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyServiceProxyTask do
  context '#call' do
    let(:source) { instance_double(ThreeScaleToolbox::Entities::Service, 'source') }
    let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target') }
    let(:target_id) { 2 }
    let(:source_attrs) do
      {
        'backend_version' => '1',
        'deployment_option' => 'self_managed',
      }
    end
    let(:source_proxy) do
      {
        'service_id' => 1,
        'endpoint' => 'https://production.webtypes.com:443',
        'sandbox_endpoint' => 'https://sandbox.webtypes.com:443',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'api_backend' => 'https://echo-api.3scale.net:443',
        'links' => []
      }
    end
    subject { described_class.new(source: source, target: target) }

    before :each do
      allow(source).to receive(:attrs).and_return(source_attrs)
      expect(source).to receive(:proxy).and_return(source_proxy)
      allow(target).to receive(:id).and_return(target_id)
    end

    it 'it calls update_proxy method' do
      expect(target).to receive(:update_proxy).with(source_proxy)
      expect { subject.call }.to output(/updated proxy of #{target_id}/).to_stdout
    end

    context 'when oidc service' do
      let(:source_attrs) do
        {
          'backend_version' => 'oidc'
        }
      end
      let(:source_oidc) do
        {
          'id' => 6562,
          'standard_flow_enabled' => false,
          'implicit_flow_enabled' =>  true,
          'service_accounts_enabled' =>  false,
          'direct_access_grants_enabled' => false
        }
      end

      it 'oidc settings copied' do
        expect(target).to receive(:update_proxy).with(source_proxy)
        expect(source).to receive(:oidc).and_return(source_proxy)
        expect(target).to receive(:update_oidc).with(source_proxy)
        expect { subject.call }.to output(/updated proxy of #{target_id}/).to_stdout
      end
    end

    context 'when gateway is hosted' do
      let(:source_attrs) do
        {
          'backend_version' => '1',
          'deployment_option' => 'hosted',
        }
      end

      it 'endpoint not copied' do
        expect(target).to receive(:update_proxy).with(hash_excluding('endpoint'))
        subject.call
      end

      it 'sandbox_endpoint not copied' do
        expect(target).to receive(:update_proxy).with(hash_excluding('sandbox_endpoint'))
        subject.call
      end
    end
  end
end
