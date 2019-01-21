RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMappingRulesStep do
  let(:service) { double('service') }
  let(:op0) { double('op0') }
  let(:op1) { double('op1') }
  let(:operations) { [op0, op1] }
  let(:openapi_context) { { operations: operations, target: service } }
  let(:mapping_rule_0) { double('mapping_rule_0') }
  let(:mapping_rule_1) { double('mapping_rule_1') }
  subject { described_class.new(openapi_context) }

  context '#call' do
    before :each do
      allow(op0).to receive(:mapping_rule).and_return(mapping_rule_0)
      allow(op0).to receive(:http_method).and_return('http_method_0')
      allow(op0).to receive(:pattern).and_return('pattern_0')

      allow(op1).to receive(:mapping_rule).and_return(mapping_rule_1)
      allow(op1).to receive(:http_method).and_return('http_method_1')
      allow(op1).to receive(:pattern).and_return('pattern_1')

      allow(service).to receive(:create_mapping_rule)
    end

    it 'mapping rule from "op0" created' do
      expect(service).to receive(:create_mapping_rule).with(mapping_rule_0)
      expect { subject.call }.to output(/Created http_method_0 pattern_0 endpoint/).to_stdout
    end

    it 'mapping rule from "op1" created' do
      expect(service).to receive(:create_mapping_rule).with(mapping_rule_1)
      expect { subject.call }.to output(/Created http_method_1 pattern_1 endpoint/).to_stdout
    end
  end
end
