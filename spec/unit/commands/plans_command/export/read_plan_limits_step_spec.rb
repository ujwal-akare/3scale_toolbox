RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanLimitsStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:hits_metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:hits_metric_id) { 1 }
  let(:method_0) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_0_id) { 2 }
  let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:metric_0_id) { 3 }
  let(:plan_system_name) { 'myplan' }
  let(:plan_limits) { [] }
  let(:context) do
    {
      threescale_client: threescale_client,
      service_system_name: service_system_name,
      plan_system_name: plan_system_name
    }
  end
  let(:result) { context[:result] }
  let(:service_metrics) { [] }
  let(:service_methods) { [] }
  subject { described_class.new(context) }

  context '#call' do
    before :example do
      allow(hits_metric).to receive(:id).and_return(hits_metric_id)
      allow(hits_metric).to receive(:system_name).and_return('hits')
      allow(method_0).to receive(:id).and_return(method_0_id)
      allow(method_0).to receive(:system_name).and_return('method_01')
      allow(metric_0).to receive(:system_name).and_return('metric_01')
      allow(metric_0).to receive(:id).and_return(metric_0_id)
      allow(service).to receive(:metrics).and_return(service_metrics)
      allow(service).to receive(:methods).and_return(service_methods)
      allow(service).to receive(:hits).and_return(hits_metric)
      expect(service_class).to receive(:find).with(hash_including(service_info))
                                             .and_return(service)
      expect(plan_class).to receive(:find).with(hash_including(service: service,
                                                               ref: plan_system_name))
                                          .and_return(plan)
      expect(plan).to receive(:limits).and_return(plan_limits)
    end

    context 'when no plan limits' do
      it 'resulting limits list is empty' do
        subject.call
        expect(result).not_to be_nil
        expect(result[:limits]).to be_empty
      end
    end

    context 'when there are limits' do
      let(:limit_for_metric) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_for_metric_attrs) do
        { 'period' => 'year', 'value' => 1000, 'metric_id' => metric_0_id }
      end
      let(:limit_for_method) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_for_method_attrs) do
        { 'period' => 'day', 'value' => 1000, 'metric_id' => method_0_id }
      end
      let(:plan_limits) { [limit_for_metric, limit_for_method] }
      let(:service_methods) { [ method_0 ] }
      let(:service_metrics) { [metric_0, hits_metric] }

      before :example do
        allow(limit_for_metric).to receive(:attrs).and_return(limit_for_metric_attrs)
        allow(limit_for_metric).to receive(:period).and_return(limit_for_metric_attrs.fetch('period'))
        allow(limit_for_metric).to receive(:value).and_return(limit_for_metric_attrs.fetch('value'))
        allow(limit_for_metric).to receive(:metric_id).and_return(limit_for_metric_attrs.fetch('metric_id'))
        allow(limit_for_metric).to receive(:id).and_return(1)
        allow(limit_for_method).to receive(:attrs).and_return(limit_for_method_attrs)
        allow(limit_for_method).to receive(:period).and_return(limit_for_method_attrs.fetch('period'))
        allow(limit_for_method).to receive(:value).and_return(limit_for_method_attrs.fetch('value'))
        allow(limit_for_method).to receive(:metric_id).and_return(limit_for_method_attrs.fetch('metric_id'))
        allow(limit_for_method).to receive(:id).and_return(2)
      end

      it 'limit addded' do
        subject.call
        expect(result).not_to be_nil
        expect(result[:limits].size).to eq(2)
        expect(result[:limits][0]).to include(limit_for_metric.attrs)
        expect(result[:limits][1]).to include(limit_for_method.attrs)
      end

      it 'metric info addded for limit refering to metric' do
        subject.call
        expect(result[:limits][0]).to include('metric' => { 'type' => 'metric',
                                                            'system_name' => 'metric_01' })
      end
      it 'metric info addded for limit refering to method' do
        subject.call
        expect(result[:limits][1]).to include('metric' => { 'type' => 'method',
                                                            'system_name' => 'method_01' })
      end

      context 'limit refer to metric not in service list' do
        let(:service_metrics) { [] }
        it 'then error raised' do
          expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                 /referencing to metric id/)
        end
      end
    end
  end
end
