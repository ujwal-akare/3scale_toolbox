RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ImportPricingRulesStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:plan_system_name) { 'myplan' }
  let(:plan_pricingrules) { [] }
  let(:resource_pricingrules) { [] }
  let(:hits_metric_id) { 1 }
  let(:service_metric) { { 'id' => hits_metric_id, 'system_name' => 'hits' } }
  let(:service_metrics) { [service_metric] }
  let(:artifacts_resource) do
    {
      'pricingrules' => resource_pricingrules
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
      allow(plan).to receive(:pricing_rules).and_return(plan_pricingrules)
      allow(service).to receive(:metrics).and_return(service_metrics)
      allow(service).to receive(:hits).and_return(service_metric)
    end

    context 'no missing pricingrules' do
      it 'then no pricingrules created' do
        expect { subject.call }.not_to output.to_stdout
      end

      context 'cost_per_unit types different' do
        let(:resource_pricingrule) do
          {
            'cost_per_unit' => 1.0, 'min' => 1,
            'max' => 100, 'metric_system_name' => 'hits'
          }
        end
        let(:plan_pricingrule) do
          {
            'cost_per_unit' => '1.0', 'min' => 1,
            'max' => 100, 'metric_id' => hits_metric_id 
          }
        end
        let(:resource_pricingrules) { [resource_pricingrule] }
        let(:plan_pricingrules) { [plan_pricingrule] }

        it 'then no pricingrules created' do
          expect { subject.call }.not_to output.to_stdout
        end
      end
    end

    context 'with missing pricingrules' do
      let(:resource_pricingrule) do
        {
          'cost_per_unit' => 1.0, 'min' => 1,
          'max' => 100, 'metric_system_name' => 'hits'
        }
      end
      let(:resource_pricingrules) { [resource_pricingrule] }

      before :example do
      end

      it 'then pricingrules are created' do
        expected_pr_attrs = resource_pricingrule.reject { |k, _v| k == 'metric_system_name' }
        expect(plan).to receive(:create_pricing_rule).with(hits_metric_id, hash_including(expected_pr_attrs))
                                                     .and_return('id' => 1000)
        expect { subject.call }.to output(/Created plan pricing rule/).to_stdout
      end

      context 'and create_pricing_rule returns error' do
        it 'then error raised' do
          expect(plan).to receive(:create_pricing_rule).and_return('errors' => 'some error')
          expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                 /Plan pricing rule has not been created/)
        end
      end
    end
  end
end
