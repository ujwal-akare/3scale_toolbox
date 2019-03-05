require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Tasks::CopyPoliciesTask do
  context '#call' do
    let(:source) { double('source') }
    let(:target) { double('target') }
    let(:source_policies) { [] }

    subject { described_class.new(source: source, target: target) }

    it 'does not call create_method method' do
      expect(source).to receive(:policies).and_return(source_policies)
      expect(target).to receive(:update_policies).with('policies_config' => source_policies)
      expect { subject.call }.to output.to_stdout
    end
  end
end
