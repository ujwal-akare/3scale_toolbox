RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Show::ShowSubcommand do
  let(:arguments) do
    {
      plan_ref: 'someplan', service_ref: 'someservice',
      remote: 'https://destination_key@destination.example.com'
    }
  end
  let(:options) {}
  let(:remote) { instance_double('ThreeScale::API') }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
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

    context 'when plan not found' do
      before :example do
        expect(plan_class).to receive(:find).and_return(nil)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Application plan someplan does not exist/)
      end
    end

    context 'when plan found' do
      let(:plan_attrs) { { 'name' => 'planA' } }
      before :example do
        expect(plan_class).to receive(:find).and_return(plan)
      end

      it 'name is shown' do
        expect(plan).to receive(:show).and_return(plan_attrs)
        expect { subject.run }.to output(/planA/).to_stdout
      end
    end
  end
end
