RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:mappingrule_class) { class_double(ThreeScaleToolbox::Entities::MappingRule).as_stubbed_const }
    let(:metric_hits) { { 'id' => 99, 'name' => 'hits', 'system_name' => 'hits' } }
    let(:source_metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:target_metric_1) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:source_mapping_rule_01) { instance_double(ThreeScaleToolbox::Entities::MappingRule) }
    let(:source_mapping_rule_02) { instance_double(ThreeScaleToolbox::Entities::MappingRule) }
    let(:target_mapping_rule_01) { instance_double(ThreeScaleToolbox::Entities::MappingRule) }
    let(:source_mapping_rule_02_attrs) do 
      { 'metric_id' => 1, 'pattern' => '/rule02', 'http_method' => 'POST', 'delta' => 1 } 
    end

    subject { described_class.new(source: source, target: target) }

    before :each do
      allow(source).to receive(:remote).and_return(remote)
      allow(target).to receive(:remote).and_return(remote)
      allow(source).to receive(:mapping_rules).and_return(source_mapping_rules)
      allow(target).to receive(:mapping_rules).and_return(target_mapping_rules)
      allow(source).to receive(:metrics).and_return(source_metrics)
      allow(source).to receive(:methods).and_return([])
      allow(target).to receive(:metrics).and_return(target_metrics)
      allow(target).to receive(:methods).and_return([])
      allow(source_metric_0).to receive(:id).and_return(1)
      allow(source_metric_0).to receive(:system_name).and_return('metric_0')
      allow(target_metric_1).to receive(:id).and_return(2)
      allow(target_metric_1).to receive(:system_name).and_return('metric_0')
      allow(source_mapping_rule_01).to receive(:id).and_return(1122)
      allow(source_mapping_rule_01).to receive(:metric_id).and_return(1)
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
      allow(target_mapping_rule_01).to receive(:metric_id).and_return(2)
      allow(target_mapping_rule_01).to receive(:pattern).and_return('/rule01')
      allow(target_mapping_rule_01).to receive(:http_method).and_return('GET')
      allow(target_mapping_rule_01).to receive(:delta).and_return(1)
    end

    context 'no missing rules' do
      # missing rules is an empty set
      let(:source_metrics) { [source_metric_0] }
      let(:target_metrics) { [target_metric_1] }
      let(:source_mapping_rules) { [source_mapping_rule_01] }
      let(:target_mapping_rules) { [target_mapping_rule_01] }

      it 'does not call create_mapping_rule method' do
        expect { subject.call }.to output(/created 0 mapping rules/).to_stdout
      end
    end

    context '1 missing rule' do
      let(:source_metrics) { [source_metric_0] }
      let(:target_metrics) { [target_metric_1] }
      let(:source_mapping_rules) { [source_mapping_rule_01, source_mapping_rule_02] }
      let(:target_mapping_rules) { [target_mapping_rule_01] }

      it 'it calls create_mapping_rule method' do
        # source_mapping_rule_02 will be created
        expect(mappingrule_class).to receive(:create).with(
          service: target,
          attrs: hash_including(source_mapping_rule_02_attrs.merge('metric_id' => target_metric_1.id))
        )
        expect { subject.call }.to output(/created 1 mapping rules/).to_stdout
      end
    end
  end
end
