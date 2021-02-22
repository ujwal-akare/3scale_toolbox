RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMappingRulesTask do
  let(:backendmappingrule_class) { class_double(ThreeScaleToolbox::Entities::BackendMappingRule).as_stubbed_const }
  let(:source_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_backend') }
  let(:target_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_backend') }
  let(:metric_src_id) { 1 }
  let(:metric_tgt_id) { 2 }
  let(:mr_src_0) { instance_double(ThreeScaleToolbox::Entities::BackendMappingRule) }
  let(:mr_src_0_attrs) do
    { 'metric_id' => metric_src_id, 'pattern' => '/pets', 'http_method' => 'GET', 'delta' => 2 }
  end
  let(:mr_src_1) { instance_double(ThreeScaleToolbox::Entities::BackendMappingRule) }
  let(:mr_tgt) { instance_double(ThreeScaleToolbox::Entities::BackendMappingRule) }
  let(:source_mappingrules) { [] }
  let(:target_mappingrules) { [] }
  let(:metrics_mapping) { { metric_src_id => metric_tgt_id } }
  let(:context)  do
    {
      source_backend: source_backend,
      target_backend: target_backend
    }
  end
  subject { described_class.new(context) }

  context '#run' do
    before :each do
      allow(source_backend).to receive(:metrics_mapping).and_return(metrics_mapping)
      allow(mr_src_0).to receive(:id).and_return(1)
      allow(mr_src_0).to receive(:metric_id).and_return(mr_src_0_attrs.fetch('metric_id'))
      allow(mr_src_0).to receive(:pattern).and_return(mr_src_0_attrs.fetch('pattern'))
      allow(mr_src_0).to receive(:http_method).and_return(mr_src_0_attrs.fetch('http_method'))
      allow(mr_src_0).to receive(:delta).and_return(mr_src_0_attrs.fetch('delta'))
      allow(mr_src_0).to receive(:attrs).and_return(mr_src_0_attrs)
      allow(mr_src_1).to receive(:id).and_return(2)
      allow(mr_src_1).to receive(:metric_id).and_return(metric_src_id)
      allow(mr_src_1).to receive(:pattern).and_return('/cars')
      allow(mr_src_1).to receive(:http_method).and_return('GET')
      allow(mr_src_1).to receive(:delta).and_return(2)
      allow(mr_tgt).to receive(:id).and_return(3)
      allow(mr_tgt).to receive(:metric_id).and_return(metric_tgt_id)
      allow(mr_tgt).to receive(:pattern).and_return('/cars')
      allow(mr_tgt).to receive(:http_method).and_return('GET')
      allow(mr_tgt).to receive(:delta).and_return(2)
      allow(source_backend).to receive(:mapping_rules).and_return(source_mappingrules)
      allow(target_backend).to receive(:mapping_rules).and_return(target_mappingrules)
    end

    it 'no mapping rules created' do
      subject.run
    end

    context 'missing mapping rules' do
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
