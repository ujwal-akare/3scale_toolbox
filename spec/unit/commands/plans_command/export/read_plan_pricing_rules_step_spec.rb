RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanPricingRulesStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double('ThreeScaleToolbox::Entities::ApplicationPlan').as_stubbed_const }
  let(:hits_metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:hits_metric_id) { 1 }
  let(:method_0) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_0_id) { 2 }
  let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:metric_0_id) { 3 }
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
        { 'cost_per_unit' => 1.0, 'min' => 1, 'max' => 100, 'metric_id' => metric_0_id }
      end
      let(:pringrule_for_method) do
        { 'cost_per_unit' => 2.0, 'min' => 1, 'max' => 100, 'metric_id' => method_0_id }
      end
      let(:plan_pricingrules) { [pringrule_for_metric, pringrule_for_method] }
      let(:service_methods) { [ method_0 ] }
      let(:service_metrics) { [metric_0, hits_metric] }

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
          { 'cost_per_unit' => '1.0', 'min' => 1, 'max' => 100, 'metric_id' => metric_0_id }
        end

        it 'cost_per_unit is converted to float' do
          subject.call
          expect(result[:pricingrules][0]).to include('cost_per_unit' => 1.0)
        end
      end
    end
  end
end
