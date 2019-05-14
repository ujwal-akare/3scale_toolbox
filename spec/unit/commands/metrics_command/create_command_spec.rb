RSpec.describe ThreeScaleToolbox::Commands::MetricsCommand::Create::CreateSubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com',
      metric_name: 'some metric'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:metric_class) { class_double(ThreeScaleToolbox::Entities::Metric).as_stubbed_const }
  let(:metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:expected_basic_attrs) do
    {
      'friendly_name' => arguments[:metric_name],
      'unit' => 'hit'
    }
  end
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

    context 'when metric is created' do
      let(:expected_attrs) { expected_basic_attrs }
      before :example do
        expect(metric_class).to receive(:create).with(service: service, attrs: expected_attrs)
                                                .and_return(metric)
        expect(metric).to receive(:id).and_return('1')
      end

      it do
        expect { subject.run }.to output(/Created metric id: 1/).to_stdout
      end

      context 'with disable option' do
        let(:options) { { disabled: true } }

        it 'metric disabled' do
          expect(metric).to receive(:disable)
          expect { subject.run }.to output(/Created metric id: 1/).to_stdout
        end
      end

      context 'with other options' do
        let(:options) do
          {
            'unit': 'myunit',
            'system-name': 'a',
            description: 'c'
          }
        end
        let(:expected_attrs) do
          expected_basic_attrs.merge('system_name' => 'a', 'unit' => 'myunit',
                                     'description' => 'c')
        end

        it 'metric created with expected params' do
          expect { subject.run }.to output(/Created metric id: 1/).to_stdout
        end
      end
    end
  end
end
