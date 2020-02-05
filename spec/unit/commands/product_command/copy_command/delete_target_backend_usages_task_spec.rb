RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::CopyCommand::DeleteExistingTargetBackendUsagesTask do
  let(:source) { instance_double(ThreeScaleToolbox::Entities::Service, 'source')  }
  let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target')  }
  let(:source_usage_01) do
    ThreeScaleToolbox::Entities::BackendUsage.new(
      id: 1, product: source, attrs: { 'backend_id' => 1, 'path' => '/v1' }
    )
  end
  let(:source_usage_02) do
    ThreeScaleToolbox::Entities::BackendUsage.new(
      id: 2, product: source, attrs: { 'backend_id' => 2, 'path' => '/v2' }
    )
  end
  let(:target_usage_01) do
    ThreeScaleToolbox::Entities::BackendUsage.new(
      id: 100, product: target, attrs: { 'backend_id' => 10, 'path' => '/v1' }
    )
  end
  let(:target_usage_02) do
    ThreeScaleToolbox::Entities::BackendUsage.new(
      id: 101, product: target, attrs: { 'backend_id' => 11, 'path' => '/somethinglese' }
    )
  end
  let(:source_list) { [source_usage_01, source_usage_02] }
  let(:target_list) { [target_usage_01, target_usage_02] }
  let(:context) { { target: target, source: source } }
  subject { described_class.new(context) }

  context '#call' do
    before :each do
      allow(source).to receive(:remote)
      allow(target).to receive(:remote)
      expect(source).to receive(:backend_usage_list).and_return(source_list)
      expect(target).to receive(:backend_usage_list).and_return(target_list)
    end

    it 'only target_usage_01 is deleted' do
      expect(target_usage_01).to receive(:delete)
      subject.call
    end
  end
end
