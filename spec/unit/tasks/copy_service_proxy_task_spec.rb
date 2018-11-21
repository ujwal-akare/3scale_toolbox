require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Tasks::CopyServiceProxyTask do
  context '#call' do
    let(:source) { double('source') }
    let(:target) { double('target') }
    let(:target_id) { 2 }
    let(:source_proxy) do
      {
        'service_id' => 1,
        'endpoint' => 'https://production.webtypes.com:443',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'api_backend': 'https://echo-api.3scale.net:443',
        'links' => []
      }
    end
    subject { described_class.new(source: source, target: target) }

    context '1 missing rule' do
      it 'it calls update_proxy method' do
        expect(source).to receive(:show_proxy).and_return(source_proxy)
        expect(target).to receive(:update_proxy).with(source_proxy)
        expect(target).to receive(:id).and_return(target_id)
        expect { subject.call }.to output(/updated proxy of #{target_id}/).to_stdout
      end
    end
  end
end
