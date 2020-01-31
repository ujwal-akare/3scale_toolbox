RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMappingRulesTask do
  let(:backendmappingrule_class) { class_double(ThreeScaleToolbox::Entities::BackendMappingRule).as_stubbed_const }
  let(:source_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_backend') }
  let(:target_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_backend') }
  let(:metric_src) { instance_double(ThreeScaleToolbox::Entities::BackendMetric) }
  let(:metric_tgt) { instance_double(ThreeScaleToolbox::Entities::BackendMetric) }
  let(:metric_src_id) { 1 }
  let(:metric_tgt_id) { 2 }
  let(:source_metrics) { [metric_src] }
  let(:target_metrics) { [metric_tgt] }
  let(:source_mappingrules) { [] }
  let(:target_mappingrules) { [] }
  let(:context)  do
    {
      source_backend: source_backend,
      target_backend: target_backend
    }
  end
  subject { described_class.new(context) }

  context '#run' do
    before :each do
      allow(source_backend).to receive(:hits)
      allow(target_backend).to receive(:hits)
      allow(source_backend).to receive(:remote)
      allow(target_backend).to receive(:remote)
      expect(source_backend).to receive(:metrics).and_return(source_metrics)
      expect(target_backend).to receive(:metrics).and_return(target_metrics)
      expect(source_backend).to receive(:methods).and_return([])
      expect(target_backend).to receive(:methods).and_return([])
      expect(source_backend).to receive(:mapping_rules).and_return(source_mappingrules)
      expect(target_backend).to receive(:mapping_rules).and_return(target_mappingrules)
      allow(metric_src).to receive(:system_name).and_return('system_name_0')
      allow(metric_src).to receive(:id).and_return(metric_src_id)
      allow(metric_tgt).to receive(:system_name).and_return('system_name_0')
      allow(metric_tgt).to receive(:id).and_return(metric_tgt_id)
    end

    it 'no mapping rules created' do
      subject.run
    end

    context 'missing mapping rules' do
      let(:mr_src_0_attrs) do
        {
          'pattern' => '/pets',
          'http_method' => 'GET',
          'delta' => '2',
          'metric_id' => metric_src_id
        }
      end
      let(:mr_src_0) do
        ThreeScaleToolbox::Entities::BackendMappingRule.new(id: 10,
                                                            backend: source_backend,
                                                            attrs: mr_src_0_attrs)
      end
      let(:mr_src_1_attrs) do
        {
          'pattern' => '/cars',
          'http_method' => 'GET',
          'delta' => '2',
          'metric_id' => metric_src_id
        }
      end
      let(:mr_src_1) do
        ThreeScaleToolbox::Entities::BackendMappingRule.new(id: 11,
                                                            backend: source_backend,
                                                            attrs: mr_src_1_attrs)
      end
      let(:mr_tgt_attrs) do
        {
          'pattern' => '/cars',
          'http_method' => 'GET',
          'delta' => '2',
          'metric_id' => metric_tgt_id
        }
      end
      let(:mr_tgt) do
        ThreeScaleToolbox::Entities::BackendMappingRule.new(id: 11,
                                                            backend: target_backend,
                                                            attrs: mr_tgt_attrs)
      end
      let(:source_mappingrules) { [mr_src_0, mr_src_1] }
      let(:target_mappingrules) { [mr_tgt] }

      it 'created' do
        expected_attrs = mr_src_0_attrs.merge('metric_id' => metric_tgt_id)
        expect(backendmappingrule_class).to receive(:create).with(backend: target_backend,
                                                                  attrs: expected_attrs)

        subject.run
      end
    end
  end
end
