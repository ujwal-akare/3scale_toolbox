RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:metric_class) { class_double('ThreeScaleToolbox::Entities::Metric').as_stubbed_const }
    let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:metric_0_attrs) { { 'system_name' => 'metric_0', 'name' => 'metric_0' } }
    let(:metric_1) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:task_context) { { source: source, target: target, logger: Logger.new('/dev/null') } }

    subject { described_class.new(task_context) }

    before :each do
      allow(source).to receive(:metrics).and_return(source_metrics)
      allow(target).to receive(:metrics).and_return(target_metrics)
      allow(metric_0).to receive(:attrs).and_return(metric_0_attrs)
      allow(metric_0).to receive(:system_name).and_return(metric_0_attrs.fetch('system_name'))
      allow(metric_1).to receive(:system_name).and_return('metric_1')
    end

    context 'no missing metrics' do
      # missing metrics is an empty set
      let(:source_metrics) { [metric_0] }
      let(:target_metrics) { [metric_0] }

      it 'does not call create_metric method' do
        subject.call
        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_metrics_created')
        expect(task_context.dig(:report, 'missing_metrics_created')).to eq(0)
      end
    end

    context '1 missing rule' do
      let(:source_metrics) { [metric_0] }
      let(:target_metrics) { [metric_1] }

      it 'it calls create_metric method' do
        expect(metric_class).to receive(:create).with(service: target, attrs: hash_including(metric_0_attrs))

        subject.call
        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_metrics_created')
        expect(task_context.dig(:report, 'missing_metrics_created')).to eq(1)
      end
    end
  end
end
