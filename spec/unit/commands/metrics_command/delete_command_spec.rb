RSpec.describe ThreeScaleToolbox::Commands::MetricsCommand::Delete::DeleteSubcommand do
  let(:arguments) do
    {
      metric_ref: 'somemetric', service_ref: 'someservice',
      remote: 'https://destination_key@destination.example.com'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:metric_class) { class_double(ThreeScaleToolbox::Entities::Metric).as_stubbed_const }
  let(:metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
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

    context 'when metric not found' do
      before :example do
        expect(metric_class).to receive(:find).with(service: service,
                                                    ref: arguments[:metric_ref]).and_return(nil)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Metric somemetric does not exist/)
      end
    end

    context 'when metric found' do
      before :example do
        expect(metric_class).to receive(:find).and_return(metric)
        expect(metric).to receive(:id).and_return('1')
      end

      it do
        expect(metric).to receive(:delete)
        expect { subject.run }.to output(/Metric id: 1 deleted/).to_stdout
      end
    end
  end
end
