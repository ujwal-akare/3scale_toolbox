RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMetricsTask do
  let(:backendmetric_class) { class_double(ThreeScaleToolbox::Entities::BackendMetric).as_stubbed_const }
  let(:source_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_backend') }
  let(:target_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_backend') }
  let(:source_metrics) { [] }
  let(:target_metrics) { [] }
  let(:context)  do
    {
      source_backend: source_backend,
      target_backend: target_backend
    }
  end
  subject { described_class.new(context) }

  context '#run' do
    before :each do
      expect(source_backend).to receive(:metrics).and_return(source_metrics)
      expect(target_backend).to receive(:metrics).and_return(target_metrics)
    end

    it 'no metric created' do
      subject.run
    end

    context 'only missing metrics created' do
      let(:metric_src_0) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'metric_src_0') }
      let(:metric_src_1) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'metric_src_1') }
      let(:metric_src_1_attrs) { { 'name' => 'metric_1' } }
      let(:metric_tgt) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'metric_tgt') }
      let(:source_metrics) { [metric_src_0, metric_src_1] }
      let(:target_metrics) { [metric_tgt] }

      it 'metric with same system_name not created' do
        allow(metric_src_0).to receive(:system_name).and_return('system_name_0')
        allow(metric_src_0).to receive(:friendly_name).and_return('friendly_name_0')
        allow(metric_src_1).to receive(:system_name).and_return('system_name_1')
        allow(metric_src_1).to receive(:friendly_name).and_return('friendly_name_1')
        # same as metric_src_0
        allow(metric_tgt).to receive(:system_name).and_return('system_name_0')
        allow(metric_tgt).to receive(:friendly_name).and_return('friendly_name_2')

        expect(metric_src_1).to receive(:attrs).and_return(metric_src_1_attrs)
        expect(backendmetric_class).to receive(:create).with(backend: target_backend,
                                                             attrs: metric_src_1_attrs)

        subject.run
      end

      it 'metric with same friendly_name not created' do
        allow(metric_src_0).to receive(:system_name).and_return('system_name_0')
        allow(metric_src_0).to receive(:friendly_name).and_return('friendly_name_0')
        allow(metric_src_1).to receive(:system_name).and_return('system_name_1')
        allow(metric_src_1).to receive(:friendly_name).and_return('friendly_name_1')
        allow(metric_tgt).to receive(:system_name).and_return('system_name_2')
        # same as metric_src_0
        allow(metric_tgt).to receive(:friendly_name).and_return('friendly_name_0')

        expect(metric_src_1).to receive(:attrs).and_return(metric_src_1_attrs)
        expect(backendmetric_class).to receive(:create).with(backend: target_backend,
                                                             attrs: metric_src_1_attrs)
        subject.run
      end
    end
  end
end
