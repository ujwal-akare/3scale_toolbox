RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:metric_class) { class_double('ThreeScaleToolbox::Entities::Metric').as_stubbed_const }
    let(:metric_0) do
      {
        'id' => 0,
        'name' => 'metric_0',
        'system_name' => 'metric 0',
        'unit' => '1',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:metric_1) do
      {
        'id' => 1,
        'name' => 'metric_1',
        'system_name' => 'metric 1',
        'unit' => '10',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:metrics).and_return(source_metrics)
      expect(target).to receive(:metrics).and_return(target_metrics)
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
        expect(metric_class).to receive(:create).with(service: target,
                                                      attrs: hash_including('name' => metric_0['name'],
                                                                            'system_name' => metric_0['system_name'],
                                                                            'unit' => metric_0['unit']))
        expect { subject.call }.to output(/created 1 metrics/).to_stdout
      end
    end
  end
end
