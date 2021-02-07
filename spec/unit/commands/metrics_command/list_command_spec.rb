RSpec.describe ThreeScaleToolbox::Commands::MetricsCommand::List::ListSubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:metric_0_attrs) { { 'id' => 3, 'friendly_name' => 'metric 0' } }
  let(:metric_1) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:metric_1_attrs) { { 'id' => 4, 'friendly_name' => 'metric 1' } }
  let(:hits_metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }

  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
      allow(metric_0).to receive(:attrs).and_return(metric_0_attrs)
      allow(metric_1).to receive(:attrs).and_return(metric_1_attrs)
      allow(hits_metric).to receive(:id).and_return(0)
      allow(hits_metric).to receive(:attrs).and_return({'system_name' => 'hits'})
      expect(service_class).to receive(:find).and_return(service)
      expect(subject).to receive(:threescale_client).and_return(remote)
    end

    context 'when service not found' do
      let(:service) { nil }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Service someservice does not exist/)
      end
    end

    context 'when metric list is returned' do
      let(:metrics) { [hits_metric, metric_0, metric_1] }

      before :example do
        expect(service).to receive(:metrics).and_return(metrics)
      end

      it 'hits metric in the list' do
        expect { subject.run }.to output(/hits/).to_stdout
      end

      it 'metric_1 in the list' do
        expect { subject.run }.to output(/metric 0/).to_stdout
      end

      it 'metric_2 in the list' do
        expect { subject.run }.to output(/metric 1/).to_stdout
      end
    end
  end
end
