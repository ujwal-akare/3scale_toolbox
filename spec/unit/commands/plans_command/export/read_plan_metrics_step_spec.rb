RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanMetrics do
  let(:method_1) { { 'id' => '01' } }
  let(:method_2) { { 'id' => '02' } }
  let(:metric_3) { { 'id' => '03' } }
  let(:method_4) { { 'id' => '04' } }
  let(:metric_5) { { 'id' => '05' } }
  let(:method_6) { { 'id' => '06' } }
  let(:limit_1) { { 'metric_id' => method_1['id'], 'metric' => { 'type' => 'method' } } }
  let(:limit_2) { { 'metric_id' => method_2['id'], 'metric' => { 'type' => 'method' } } }
  let(:limit_3) { { 'metric_id' => metric_3['id'], 'metric' => { 'type' => 'metric' } } }
  let(:pr_1) { { 'metric_id' => method_1['id'], 'metric' => { 'type' => 'method' } } }
  let(:pr_2) { { 'metric_id' => method_4['id'], 'metric' => { 'type' => 'method' } } }
  let(:pr_3) { { 'metric_id' => metric_5['id'], 'metric' => { 'type' => 'metric' } } }
  let(:resource_limits) { [limit_1, limit_2, limit_3] }
  let(:resource_pricingrules) { [pr_1, pr_2, pr_3] }
  let(:service_metrics) { [method_1, method_2, metric_3, method_4, metric_5, method_6] }
  let(:context) do
    {
      service_metrics: service_metrics,
      result: {
        limits: resource_limits,
        pricingrules: resource_pricingrules
      }
    }
  end
  let(:result) { context[:result] }
  subject { described_class.new(context) }

  context '#call' do
    before :example do
      subject.call
    end

    it 'method 01 from limits and pricingrules not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_1['id'])
    end

    it 'method 02 from limits not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_2['id'])
    end

    it 'metric 03 from limits in plan metrics' do
      expect(result[:plan_metrics]).to include(metric_3['id'] => metric_3)
    end

    it 'method 04 from pricing_rules not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_4['id'])
    end

    it 'metric 05 from pricingrules in plan metrics' do
      expect(result[:plan_metrics]).to include(metric_5['id'] => metric_5)
    end

    it 'method 06 not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_6['id'])
    end
  end
end
