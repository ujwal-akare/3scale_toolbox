RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ImportPlanFeaturesStep do
  let(:threescale_client) { double('threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:plan_system_name) { 'myplan' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:plan_features) { [] }
  let(:service_features) { [] }
  let(:resource_features) { [] }
  let(:artifacts_resource) do
    {
      'plan_features' => resource_features
    }
  end
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
      expect(service_class).to receive(:find).with(hash_including(service_info))
                                             .and_return(service)
      expect(plan_class).to receive(:find).with(hash_including(service: service,
                                                               ref: plan_system_name))
                                          .and_return(plan)
      allow(plan).to receive(:features).and_return(plan_features)
    end

    context 'no missing features' do
      it 'no features created' do
        expect { subject.call }.not_to output.to_stdout
      end
    end

    context 'with missing features' do
      let(:feature_id) { 1000 }
      let(:feature) { { 'id' => feature_id, 'system_name' => '01' } }
      let(:resource_feature) { { 'system_name' => '01' } }
      let(:resource_features) { [resource_feature] }
      let(:response_error) { { 'errors' => 'some error' } }

      before :example do
        expect(service).to receive(:features).and_return(service_features)
      end

      context 'and service feature already exists' do
        let(:service_features) { [{ 'id' => feature_id, 'system_name' => '01' }] }

        it 'service feature not created, plan feature created' do
          # service double should not receive create_feature call
          expect(plan).to receive(:create_feature).with(feature_id)
                                                  .and_return(feature)
          expect { subject.call }.to output(/Created plan feature/).to_stdout
        end

        context 'and create_plan_feature method returns error' do
          it 'error raised' do
            expect(plan).to receive(:create_feature).with(feature_id)
                                                    .and_return(response_error)
            expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                   /Plan feature has not been created/)
          end
        end
      end

      context 'and service feature does not exist' do
        it 'service and plan feature created' do
          expect(service).to receive(:create_feature).with(resource_feature)
                                                     .and_return(feature)
          expect(plan).to receive(:create_feature).with(feature_id)
                                                  .and_return(feature)
          expect { subject.call }.to output(/Created plan feature/).to_stdout
        end

        context 'when create_service_feature method returns error' do
          it 'error raised' do
            expect(service).to receive(:create_feature).with(resource_feature)
                                                       .and_return(response_error)
            expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                   /Service feature has not been created/)
          end
        end
      end
    end
  end
end
