RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ImportMetricLimitsStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:plan_system_name) { 'myplan' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:resource_limits) { [] }
  let(:hits_metric_id) { 1 }
  let(:hits_metric) { { 'id' => hits_metric_id, 'system_name' => 'hits' } }
  let(:service_metrics) { [hits_metric] }
  let(:plan_limits) { [] }
  let(:artifacts_resource) do
    {
      'limits' => resource_limits
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
      allow(plan).to receive(:limits).and_return(plan_limits)
      allow(service).to receive(:metrics).and_return(service_metrics)
      allow(service).to receive(:hits).and_return(hits_metric)
    end

    context 'existing limits' do
      let(:plan_limit) { { 'id' => 32, 'metric_id' => hits_metric_id } }
      let(:plan_limits) { [plan_limit] }

      it 'deleted' do
        expect(plan).to receive(:delete_limit).with(hits_metric_id, plan_limit.fetch('id'))
        subject.call
      end
    end

    context 'imported limits' do
      let(:resource_limit) do
        {
          'period' => 'year', 'value' => 1000, 'metric_system_name' => 'hits'
        }
      end
      let(:resource_limits) { [resource_limit] }

      it 'created' do
        expected_attrs = resource_limit.reject { |k, _v| k == 'metric_system_name' }
        expect(plan).to receive(:create_limit).with(hits_metric_id, hash_including(expected_attrs))
                                              .and_return('id' => 1000)
        subject.call
      end
    end
  end
end
