RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::CopyCommand::DeleteTargetBackendUsagesTask do
  let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target')  }
  let(:backend_usage_01) { instance_double(ThreeScaleToolbox::Entities::BackendUsage) }
  let(:backend_usage_list) { [backend_usage_01] }
  let(:context) { { target: target } }
  subject { described_class.new(context) }

  context '#call' do
    before :each do
      expect(target).to receive(:backend_usage_list).and_return(backend_usage_list)
      expect(backend_usage_01).to receive(:delete)
    end

    it 'backend usage items should be deleted' do
      subject.call
    end
  end
end
