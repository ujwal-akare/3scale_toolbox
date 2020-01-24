RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:metric_hits) { { 'id' => 99, 'name' => 'hits', 'system_name' => 'hits' } }
    let(:metric_0) do
      {
        'id' => 0,
        'name' => 'metric_0',
        'system_name' => 'the_metric',
        'unit': '1',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:metric_1) do
      {
        'id' => 1,
        'name' => 'metric_1',
        'system_name' => 'the_metric',
        'unit': '1',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:source_mapping_rule_01) do
      {
        'id' => 0,
        'metric_id' => 0,
        'pattern' => '/rule01',
        'http_method' => 'GET',
        'delta' => 1,
        'redirect_url' => nil,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:source_mapping_rule_02) do
      {
        'id' => 10,
        'metric_id' => 0,
        'pattern' => '/rule10',
        'http_method' => 'POST',
        'delta' => 10,
        'redirect_url' => nil,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:target_mapping_rule_01) do
      {
        'id' => 1,
        'metric_id' => 1,
        'pattern' => '/rule01',
        'http_method' => 'GET',
        'delta' => 1,
        'redirect_url' => nil,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end

    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:mapping_rules).and_return(source_mapping_rules)
      expect(target).to receive(:mapping_rules).and_return(target_mapping_rules)
      expect(source).to receive(:metrics).and_return(source_metrics)
      expect(source).to receive(:hits).and_return(metric_hits)
      expect(source).to receive(:methods).and_return([])
      expect(target).to receive(:metrics).and_return(target_metrics)
      expect(target).to receive(:hits).and_return(metric_hits)
      expect(target).to receive(:methods).and_return([])
    end

    context 'no missing rules' do
      # missing rules is an empty set
      let(:source_metrics) { [metric_0] }
      let(:target_metrics) { [metric_1] }
      let(:source_mapping_rules) { [source_mapping_rule_01] }
      let(:target_mapping_rules) { [target_mapping_rule_01] }

      it 'does not call create_mapping_rule method' do
        expect { subject.call }.to output(/created 0 mapping rules/).to_stdout
      end
    end

    context '1 missing rule' do
      let(:source_metrics) { [metric_0] }
      let(:target_metrics) { [metric_1] }
      let(:source_mapping_rules) { [source_mapping_rule_01, source_mapping_rule_02] }
      let(:target_mapping_rules) { [target_mapping_rule_01] }

      it 'it calls create_mapping_rule method' do
        # source_mapping_rule_02 will be updated, match arguments with explicit values
        # from source_mapping_rule_02
        expect(target).to receive(:create_mapping_rule).with(
          hash_including('metric_id' => metric_1['id'], 'pattern' => '/rule10',
                         'http_method' => 'POST', 'delta' => 10)
        )
        expect { subject.call }.to output(/created 1 mapping rules/).to_stdout
      end
    end
  end
end
