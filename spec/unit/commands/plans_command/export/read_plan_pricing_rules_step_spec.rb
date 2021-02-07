RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanPricingRulesStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:plan) { instance_double('ThreeScaleToolbox::Entities::ApplicationPlan') }
  let(:plan_system_name) { 'myplan' }
  let(:plan_pricingrules) { [] }
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
      expect(plan).to receive(:pricing_rules).and_return(plan_pricingrules)
    end

    context 'when no plan pricingrules' do
      it 'resulting pricingrules list is empty' do
        subject.call
        expect(result).not_to be_nil
        expect(result[:pricingrules]).to be_empty
      end
    end

    context 'when there are pricingrules' do
      let(:pringrule_for_metric) do
        { 'cost_per_unit' => 1.0, 'min' => 1, 'max' => 100, 'metric_id' => '01' }
      end
      let(:pringrule_for_method) do
        { 'cost_per_unit' => 2.0, 'min' => 1, 'max' => 100, 'metric_id' => '02' }
      end
      let(:plan_pricingrules) { [pringrule_for_metric, pringrule_for_method] }
      let(:service_methods) do
        [
          { 'id' => '02', 'name' => 'Method 01', 'system_name' => 'method_01' }
        ]
      end
      let(:hits_metric) { { 'id' => '100', 'system_name' => 'hits' } }
      # service metrics include service methods
      let(:service_metrics) do
        service_methods + [
          { 'id' => '01', 'name' => 'Metric 01', 'system_name' => 'metric_01' },
          hits_metric
        ]
      end

      before :example do
        allow(service).to receive(:hits).and_return(hits_metric)
        allow(service).to receive(:metrics).and_return(service_metrics)
        allow(service).to receive(:methods).and_return(service_methods)
      end

      it 'pricingrules addded' do
        subject.call
        expect(result).not_to be_nil
        expect(result[:pricingrules].size).to eq(2)
        expect(result[:pricingrules][0]).to include(pringrule_for_metric)
        expect(result[:pricingrules][1]).to include(pringrule_for_method)
      end

      it 'metric info addded for pricingrule refering to metric' do
        subject.call
        expect(result[:pricingrules][0]).to include('metric' => { 'type' => 'metric',
                                                                  'system_name' => 'metric_01' })
      end
      it 'metric info addded for pricingrule refering to method' do
        subject.call
        expect(result[:pricingrules][1]).to include('metric' => { 'type' => 'method',
                                                                  'system_name' => 'method_01' })
      end

      context 'pricingrule refer to metric not in service list' do
        let(:service_metrics) { [] }
        it 'then error raised' do
          expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                                 /referencing to metric id/)
        end
      end

      context 'cost_per_unit is string' do
        let(:pringrule_for_metric) do
          { 'cost_per_unit' => '1.0', 'min' => 1, 'max' => 100, 'metric_id' => '01' }
        end

        it 'cost_per_unit is converted to float' do
          subject.call
          expect(result[:pricingrules][0]).to include('cost_per_unit' => 1.0)
        end
      end
    end
  end
end
