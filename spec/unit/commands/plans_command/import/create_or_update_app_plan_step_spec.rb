RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::CreateOrUpdateAppPlanStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:plan_system_name) { 'myplan' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:artifacts_resource) do
    {
      'plan' => {
        'name' => 'some plan name'
      }
    }
  end
  let(:expected_plan_attrs) { artifacts_resource['plan'] }
  let(:context) do
    {
      threescale_client: threescale_client,
      service_system_name: service_system_name,
      plan_system_name: plan_system_name,
      artifacts_resource: artifacts_resource
    }
  end
  subject { described_class.new(context) }

  context '#call' do
    before :example do
      allow(plan).to receive(:id).and_return('1')
      expect(service_class).to receive(:find).with(hash_including(service_info))
                                             .and_return(service)
    end

    context 'when service not found' do
      let(:service) { nil }

      it 'error raised' do
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                               /Service #{service_system_name} does not exist/)
      end
    end

    context 'when application plan not found' do
      let(:expected_plan_attrs) do
        artifacts_resource['plan'].merge('system_name' => plan_system_name)
      end

      before :example do
        expect(plan_class).to receive(:find).with(hash_including(service: service))
                                            .and_return(nil)
      end

      it 'application plan is created' do
        expect(plan_class).to receive(:create).with(hash_including(service: service,
                                                                   plan_attrs: expected_plan_attrs))
                                              .and_return(plan)
        expect { subject.call }.to output.to_stdout
      end
    end

    context 'when application plan was found' do
      before :example do
        expect(plan_class).to receive(:find).with(hash_including(service: service))
                                            .and_return(plan)
        expect(plan).to receive(:update).with(expected_plan_attrs).and_return(plan_update_response)
      end

      context 'and update fails' do
        let(:plan_update_response) { { 'errors' => 'some error' } }

        it 'error raised' do
          expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                 /Could not update application plan/)
        end
      end

      context 'and update succeeds' do
        let(:plan_update_response) { { 'id' => 'some error' } }

        it do
          expect { subject.call }.to output.to_stdout
        end
      end
    end
  end
end
