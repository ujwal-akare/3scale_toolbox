RSpec.describe ThreeScaleToolbox::Commands::MetricsCommand::Apply::ApplySubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com',
      metric_ref: 'somemetric'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:metric_class) { class_double(ThreeScaleToolbox::Entities::Metric).as_stubbed_const }
  let(:metric_id) { 1 }
  let(:metric_attrs) { { 'id' => metric_id } }
  let(:metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    context 'when --disabled and --enabled set' do
      let(:options) { { disabled: true, enabled: true } }
      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /mutually exclusive/)
      end
    end

    context 'valid params' do
      before :example do
        expect(service_class).to receive(:find).and_return(service)
        expect(subject).to receive(:threescale_client).and_return(remote)
        allow(metric).to receive(:attrs).and_return(metric_attrs)
      end

      context 'when service not found' do
        let(:service) { nil }

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /Service someservice does not exist/)
        end
      end

      context 'when metric not found' do
        let(:create_attrs) do
          {
            'friendly_name' => arguments[:metric_ref],
            'unit' => 'hit',
            'system_name' => arguments[:metric_ref]
          }
        end

        before :example do
          expect(metric_class).to receive(:find).and_return(nil)
        end

        it 'metric created' do
          expect(metric_class).to receive(:create).with(service: service, attrs: create_attrs)
                                                  .and_return(metric)
          expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
        end

        context 'when name in options' do
          let(:options) { { name: 'new name' } }
          let(:create_attrs) do
            {
              'friendly_name' => options[:name],
              'unit' => 'hit',
              'system_name' => arguments[:metric_ref]
            }
          end

          it 'friendly_name overriden' do
            expect(metric_class).to receive(:create).with(service: service, attrs: create_attrs)
                                                    .and_return(metric)
            expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
          end
        end

        context 'when unit in options' do
          let(:options) { { unit: 'new unit' } }
          let(:create_attrs) do
            {
              'friendly_name' => arguments[:metric_ref],
              'unit' => 'new unit',
              'system_name' => arguments[:metric_ref]
            }
          end

          it 'unit overriden' do
            expect(metric_class).to receive(:create).with(service: service, attrs: create_attrs)
                                                    .and_return(metric)
            expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
          end
        end
      end

      context 'when metric found' do
        before :example do
          expect(metric_class).to receive(:find).and_return(metric)
        end

        context 'with no options' do
          let(:options) { {} }

          it 'metric not updated' do
            expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
          end
        end

        context 'with options' do
          let(:options) { { unit: 'bla', description: 'some descr' } }
          let(:update_attrs) { Hash[options.map { |k, v| [k.to_s, v] }] }

          it 'metric updated' do
            expect(metric).to receive(:update).with(update_attrs)
            expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
          end
        end

        context 'with disable option' do
          let(:options) { { disabled: true } }

          it 'metric disabled' do
            expect(metric).to receive(:disable)
            expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
          end
        end

        context 'with enabled option' do
          let(:options) { { enabled: true } }

          it 'metric disabled' do
            expect(metric).to receive(:enable)
            expect { subject.run }.to output(/Applied metric id: 1/).to_stdout
          end
        end
      end
    end
  end
end
