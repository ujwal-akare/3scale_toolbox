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
  let(:hits_metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:limit_0) { instance_double(ThreeScaleToolbox::Entities::Limit) }
  let(:limit_0_attrs) { { 'value' => 100 } }
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
      allow(hits_metric).to receive(:id).and_return(hits_metric_id)
      allow(hits_metric).to receive(:system_name).and_return('hits')
      allow(limit_0).to receive(:metric_id).and_return(hits_metric_id)
      allow(limit_0).to receive(:attrs).and_return(limit_0_attrs)
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
      let(:plan_limits) { [limit_0] }

      it 'deleted' do
        expect(limit_0).to receive(:delete)
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
