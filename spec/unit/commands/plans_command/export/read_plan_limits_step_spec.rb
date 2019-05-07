RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanLimitsStep do
  let(:threescale_client) { double('threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
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
  subject { described_class.new(context) }

  context '#call' do
    before :example do
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
      let(:limit_for_metric) do
        { 'period' => 'year', 'value' => 1000, 'metric_id' => '01' }
      end
      let(:limit_for_method) do
        { 'period' => 'day', 'value' => 1000, 'metric_id' => '02' }
      end
      let(:plan_limits) { [limit_for_metric, limit_for_method] }
      let(:service_methods) do
        [
          { 'id' => '02', 'name' => 'Method 01', 'system_name' => 'method_01' }
        ]
      end
      # service metrics include service methods
      let(:service_metrics) do
        service_methods + [
          { 'id' => '01', 'name' => 'Metric 01', 'system_name' => 'metric_01' }
        ]
      end

      before :example do
        expect(service).to receive(:metrics).and_return(service_metrics)
        expect(service).to receive(:methods).and_return(service_methods)
      end

      it 'limit addded' do
        subject.call
        expect(result).not_to be_nil
        expect(result[:limits].size).to eq(2)
        expect(result[:limits][0]).to include(limit_for_metric)
        expect(result[:limits][1]).to include(limit_for_method)
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
