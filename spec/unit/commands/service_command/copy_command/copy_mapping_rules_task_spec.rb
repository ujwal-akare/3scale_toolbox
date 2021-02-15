RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:metric_id_1) { 1 }
    let(:metric_id_2) { 2 }
    let(:mappingrule_class) { class_double(ThreeScaleToolbox::Entities::MappingRule).as_stubbed_const }
    let(:source_mapping_rule_01) { instance_double(ThreeScaleToolbox::Entities::MappingRule) }
    let(:source_mapping_rule_02) { instance_double(ThreeScaleToolbox::Entities::MappingRule) }
    let(:target_mapping_rule_01) { instance_double(ThreeScaleToolbox::Entities::MappingRule) }
    let(:source_mapping_rule_02_attrs) do
      { 'metric_id' => metric_id_1, 'pattern' => '/rule02', 'http_method' => 'POST', 'delta' => 1 }
    end
    let(:metrics_mapping) { { metric_id_1 => metric_id_2 } }
    let(:task_context) { { source: source, target: target, logger: Logger.new('/dev/null') } }

    subject { described_class.new(task_context) }

    before :each do
      allow(source).to receive(:metrics_mapping).and_return(metrics_mapping)
      allow(source).to receive(:mapping_rules).and_return(source_mapping_rules)
      allow(target).to receive(:mapping_rules).and_return(target_mapping_rules)
      allow(source_mapping_rule_01).to receive(:id).and_return(1122)
      allow(source_mapping_rule_01).to receive(:metric_id).and_return(metric_id_1)
      allow(source_mapping_rule_01).to receive(:pattern).and_return('/rule01')
      allow(source_mapping_rule_01).to receive(:http_method).and_return('GET')
      allow(source_mapping_rule_01).to receive(:delta).and_return(1)
      allow(source_mapping_rule_02).to receive(:id).and_return(2222)
      allow(source_mapping_rule_02).to receive(:metric_id).and_return(source_mapping_rule_02_attrs.fetch('metric_id'))
      allow(source_mapping_rule_02).to receive(:pattern).and_return(source_mapping_rule_02_attrs.fetch('pattern'))
      allow(source_mapping_rule_02).to receive(:http_method).and_return(source_mapping_rule_02_attrs.fetch('http_method'))
      allow(source_mapping_rule_02).to receive(:delta).and_return(source_mapping_rule_02_attrs.fetch('delta'))
      allow(source_mapping_rule_02).to receive(:attrs).and_return(source_mapping_rule_02_attrs)
      allow(target_mapping_rule_01).to receive(:id).and_return(1111)
      allow(target_mapping_rule_01).to receive(:metric_id).and_return(metric_id_2)
      allow(target_mapping_rule_01).to receive(:pattern).and_return('/rule01')
      allow(target_mapping_rule_01).to receive(:http_method).and_return('GET')
      allow(target_mapping_rule_01).to receive(:delta).and_return(1)
    end

    context 'no missing rules' do
      # missing rules is an empty set
      let(:source_mapping_rules) { [source_mapping_rule_01] }
      let(:target_mapping_rules) { [target_mapping_rule_01] }

      it 'does not call create_mapping_rule method' do
        subject.call
        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_mapping_rules_created')
        expect(task_context.dig(:report, 'missing_mapping_rules_created')).to eq(0)
      end
    end

    context '1 missing rule' do
      let(:source_mapping_rules) { [source_mapping_rule_01, source_mapping_rule_02] }
      let(:target_mapping_rules) { [target_mapping_rule_01] }

      it 'it calls create_mapping_rule method' do
        # source_mapping_rule_02 will be created
        expect(mappingrule_class).to receive(:create).with(
          service: target,
          attrs: hash_including(source_mapping_rule_02_attrs.merge('metric_id' => metric_id_2))
        )
        subject.call
        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_mapping_rules_created')
        expect(task_context.dig(:report, 'missing_mapping_rules_created')).to eq(1)
      end
    end
  end
end
