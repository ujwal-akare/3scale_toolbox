RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ImportPricingRulesStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service, 'myservice') }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'backend01') }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:plan_system_name) { 'myplan' }
  let(:plan_pricingrules) { [] }
  let(:resource_pricingrules) { [] }
  let(:hits_metric_id) { 1 }
  let(:hits_metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:service_metrics) { [hits_metric] }
  let(:service_methods) { [] }
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
      allow(hits_metric).to receive(:id).and_return(hits_metric_id)
      allow(hits_metric).to receive(:system_name).and_return('hits')
      expect(service_class).to receive(:find).with(hash_including(service_info))
                                             .and_return(service)
      expect(plan_class).to receive(:find).with(hash_including(service: service,
                                                               ref: plan_system_name))
                                          .and_return(plan)
      allow(plan).to receive(:pricing_rules).and_return(plan_pricingrules)
      allow(service).to receive(:metrics).and_return(service_metrics)
      allow(service).to receive(:methods).and_return(service_methods)
      allow(service).to receive(:hits).and_return(hits_metric)
    end

    context 'existing pricingrules' do
      let(:plan_pricingrule) { instance_double(ThreeScaleToolbox::Entities::PricingRule) }
      let(:plan_pricingrule_attrs) do
        {
          'id' => 32, 'cost_per_unit' => '1.0', 'min' => 1,
          'max' => 100, 'metric_id' => hits_metric_id
        }
      end
      let(:plan_pricingrules) { [plan_pricingrule] }

      before :example do
        allow(plan_pricingrule).to receive(:attrs).and_return(plan_pricingrule_attrs)
        allow(plan_pricingrule).to receive(:metric_id).and_return(plan_pricingrule_attrs.fetch('metric_id'))
      end

      it 'deleted' do
        expect(plan_pricingrule).to receive(:delete)
        subject.call
      end
    end

    context 'imported pricingrules' do
      let(:resource_pricingrule) do
        {
          'cost_per_unit' => 1.0, 'min' => 1,
          'max' => 100, 'metric_system_name' => 'hits'
        }
      end
      let(:resource_pricingrules) { [resource_pricingrule] }

      it 'created' do
        expected_pr_attrs = resource_pricingrule.reject { |k, _v| k == 'metric_system_name' }
        expect(plan).to receive(:create_pricing_rule).with(hits_metric_id, hash_including(expected_pr_attrs))
                                                     .and_return('id' => 1000)
        subject.call
      end
    end

    context 'imported pricingrule with backend metric' do
      let(:resource_pricingrule) do
        {
          'cost_per_unit' => 1.0, 'min' => 1,
          'max' => 100, 'metric_system_name' => 'hits',
          'metric_backend_system_name' => 'backend01'
        }
      end
      let(:resource_pricingrules) { [resource_pricingrule] }
      let(:backend_hits_metric) { instance_double(ThreeScaleToolbox::Entities::BackendMetric) }
      let(:backend_metrics) { [backend_hits_metric] }
      let(:backend_methods) { [] }

      before :example do
        expect(backend_class).to receive(:find_by_system_name).and_return(backend)
        allow(backend).to receive(:metrics).and_return(backend_metrics)
        allow(backend).to receive(:methods).and_return(backend_methods)
        allow(backend_hits_metric).to receive(:system_name).and_return('hits')
        allow(backend_hits_metric).to receive(:id).and_return(999)
      end

      it 'created' do
        expected_attrs = resource_pricingrule.reject { |k, _v| %w[metric_system_name metric_backend_system_name].include? k }
        expect(plan).to receive(:create_pricing_rule).with(999, hash_including(expected_attrs))
          .and_return('id' => 1000)
        subject.call
      end
    end

    context 'metric not found' do
      let(:resource_pricingrule) do
        {
          'cost_per_unit' => 1.0, 'min' => 1,
          'max' => 100, 'metric_system_name' => 'other'
        }
      end
      let(:resource_pricingrules) { [resource_pricingrule] }

      it 'raised error' do
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error, /metric \[other, \] not found/)
      end
    end
  end
end
