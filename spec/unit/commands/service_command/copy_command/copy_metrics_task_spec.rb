RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:metric_class) { class_double('ThreeScaleToolbox::Entities::Metric').as_stubbed_const }
    let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:metric_0_attrs) { { 'system_name' => 'metric_0', 'name' => 'metric_0' } }
    let(:metric_1) { instance_double(ThreeScaleToolbox::Entities::Metric) }

    subject { described_class.new(source: source, target: target) }

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
        expect { subject.call }.to output(/created 0 metrics/).to_stdout
      end
    end

    context '1 missing rule' do
      let(:source_metrics) { [metric_0] }
      let(:target_metrics) { [metric_1] }

      it 'it calls create_metric method' do
        expect(metric_class).to receive(:create).with(service: target, attrs: hash_including(metric_0_attrs))
        expect { subject.call }.to output(/created 1 metrics/).to_stdout
      end
    end
  end
end
