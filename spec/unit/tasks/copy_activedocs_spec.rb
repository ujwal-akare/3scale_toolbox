RSpec.describe ThreeScaleToolbox::Tasks::CopyActiveDocsTask do
  context '#call' do
    let(:source_service_id) { '10'}
    let(:target_service_id) { '20' }
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
    let(:activedocs0) do
      {
        'id' => 0, 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => source_service_id
      }
    end
    let(:activedocs1) do
      {
        'id' => 1, 'name' => 'ad_1', 'system_name' => 'ad_1', 'service_id' => source_service_id
      }
    end
    let(:activedocs) { [activedocs0, activedocs1] }

    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:activedocs).and_return(activedocs)
      allow(target).to receive(:id).and_return(target_service_id)
      allow(target).to receive(:remote).and_return(remote)
    end

    it 'creates all activedocs' do
      expect(remote).to receive(:create_activedocs).exactly(activedocs.size).times.and_return({})
      subject.call
    end

    it 'creates activedocs with target service id' do
      activedocs.each do
        expect(remote).to receive(:create_activedocs).with(
          hash_including('service_id' => target_service_id)
        ).and_return({})
      end
      subject.call
    end

    it 'creates activedocs with updated system_nameid' do
      activedocs.each do |ad|
        expect(remote).to receive(:create_activedocs).with(
          hash_including('system_name' => "#{ad['system_name']}#{target_service_id}")
        ).and_return({})
      end
      subject.call
    end

    it 'raises error when create failed' do
      expect(remote).to receive(:create_activedocs).and_return('errors' => 'some error')
      expect { subject.call }.to raise_error(ThreeScaleToolbox::Error)
    end
  end
end
