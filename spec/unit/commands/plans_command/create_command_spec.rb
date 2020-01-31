RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Create::CreateSubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com',
      plan_name: 'someplan'
    }
  end
  let(:options) { {} }
  let(:plan_id) { 1 }
  let(:basic_plan_attrs) { { 'name' => 'someplan' } }
  let(:plan_attrs) { basic_plan_attrs.merge('id' => plan_id) }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
      expect(service_class).to receive(:find).and_return(service)
      allow(plan).to receive(:attrs).and_return(plan_attrs)
      expect(subject).to receive(:threescale_client).and_return(remote)
    end

    context 'when service not found' do
      let(:service) { nil }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Service someservice does not exist/)
      end
    end

    context 'when app plan created' do
      let(:create_attrs) { basic_plan_attrs }

      before :example do
        expect(plan_class).to receive(:create).with(service: service, plan_attrs: create_attrs)
                                              .and_return(plan)
      end

      it do
        expect { subject.run }.to output(/Created application plan id: 1/).to_stdout
      end

      context 'with default option' do
        let(:options) { { default: true } }

        it 'plan made default' do
          expect(plan).to receive(:make_default)
          expect { subject.run }.to output(/Created application plan id: 1/).to_stdout
        end
      end

      context 'with disable option' do
        let(:options) { { disabled: true } }

        it 'plan disabled' do
          expect(plan).to receive(:disable)
          expect { subject.run }.to output(/Created application plan id: 1/).to_stdout
        end
      end

      context 'with publish option' do
        let(:options) { { publish: true } }
        let(:create_attrs) { basic_plan_attrs.merge('state' => 'published') }

        it 'plan made public' do
          expect { subject.run }.to output(/Created application plan id: 1/).to_stdout
        end
      end

      context 'with other options' do
        let(:options) do
          {
            'system-name': 'a',
            'approval-required': 'b',
            'end-user-required': 'c',
            'cost-per-month': 0,
            'setup-fee': 1,
            'trial-period-days': 2
          }
        end
        let(:expected_params) do
          {
            'system_name' => 'a',
            'approval_required' => 'b',
            'cost_per_month' => 0,
            'setup_fee' => 1,
            'trial_period_days' => 2
          }
        end
        let(:create_attrs) { basic_plan_attrs.merge(expected_params) }

        it 'plan created with expected params' do
          expect { subject.run }.to output(/Created application plan id: 1/).to_stdout
        end
      end
    end
  end
end
