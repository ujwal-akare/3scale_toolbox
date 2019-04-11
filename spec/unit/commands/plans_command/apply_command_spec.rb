RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Apply::ApplySubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com',
      plan_ref: 'someplan'
    }
  end
  let(:options) { {} }
  let(:basic_plan_attrs) { { 'name' => 'someplan' } }
  let(:remote) { instance_double('ThreeScale::API') }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    context 'when --disabled and --enabled set' do
      let(:options) { { disabled: true, enabled: true } }
      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /mutually exclusive/)
      end
    end

    context 'when --publish and --hide set' do
      let(:options) { { publish: true, hide: true } }
      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /mutually exclusive/)
      end
    end

    context 'valid params' do
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

      context 'when plan not found' do
        let(:plan_attrs) { { 'name' => 'someplan', 'system_name' => 'someplan' } }

        before :example do
          expect(plan_class).to receive(:find).and_return(nil)
          expect(plan).to receive(:id).and_return(1)
        end

        it 'plan created' do
          expect(plan_class).to receive(:create).with(service: service, plan_attrs: plan_attrs)
                                                .and_return(plan)
          expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
        end
      end

      context 'when plan found' do
        before :example do
          expect(plan_class).to receive(:find).and_return(plan)
          expect(plan).to receive(:id).and_return(1)
        end

        context 'with no options' do
          let(:options) { {} }

          it 'plan not updated' do
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end

        context 'with options' do
          let(:options) do
            {
              'approval-required': 'b',
              'end-user-required': 'c',
              'cost-per-month': 0,
              'setup-fee': 1,
              'trial-period-days': 2
            }
          end
          let(:plan_attrs) do
            {
              'approval_required' => 'b',
              'end_user_required' => 'c',
              'cost_per_month' => 0,
              'setup_fee' => 1,
              'trial_period_days' => 2
            }
          end

          it 'plan updated' do
            expect(plan).to receive(:update).with(plan_attrs)
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end

        context 'with default option' do
          let(:options) { { default: true } }

          it 'plan made default' do
            expect(plan).to receive(:make_default)
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end

        context 'with disable option' do
          let(:options) { { disabled: true } }

          it 'plan disabled' do
            expect(plan).to receive(:disable)
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end

        context 'with enabled option' do
          let(:options) { { enabled: true } }

          it 'plan disabled' do
            expect(plan).to receive(:enable)
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end

        context 'with publish option' do
          let(:options) { { publish: true } }
          let(:plan_attrs) { { 'state' => 'published' } }

          it 'plan updated published' do
            expect(plan).to receive(:update).with(plan_attrs)
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end

        context 'with hide option' do
          let(:options) { { hide: true } }
          let(:plan_attrs) { { 'state' => 'hidden' } }

          it 'plan updated hidden' do
            expect(plan).to receive(:update).with(plan_attrs)
            expect { subject.run }.to output(/Applied application plan id: 1/).to_stdout
          end
        end
      end
    end
  end
end
