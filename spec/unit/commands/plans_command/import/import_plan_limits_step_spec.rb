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
    end

    context 'no missing limits' do
      it 'then no limits created' do
        expect { subject.call }.not_to output.to_stdout
      end
    end

    context 'with missing limits' do
      let(:resource_limit) do
        {
          'period' => 'year', 'value' => 1000, 'metric_system_name' => 'hits'
        }
      end
      let(:resource_limits) { [resource_limit] }
      let(:metric_id) { 1 }
      let(:service_metric) { { 'id' => metric_id, 'system_name' => 'hits' } }
      let(:service_metrics) { [service_metric] }

      before :example do
        expect(service).to receive(:metrics).and_return(service_metrics)
        expect(service).to receive(:hits).and_return(service_metric)
      end

      it 'then limits are created' do
        expected_limit_attrs = resource_limit.reject { |k, _v| k == 'metric_system_name' }
        expect(plan).to receive(:create_limit).with(metric_id, hash_including(expected_limit_attrs))
                                              .and_return('id' => 1000)
        expect { subject.call }.to output(/Created plan limit/).to_stdout
      end

      context 'and create_limit returns error' do
        it 'then error raised' do
          expect(plan).to receive(:create_limit).and_return('errors' => 'some error')
          expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                 /Plan limit has not been created/)
        end
      end
    end
  end
end
