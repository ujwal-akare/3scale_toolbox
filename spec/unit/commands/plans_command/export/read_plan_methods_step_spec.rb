RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanMethods do
  let(:method_1) { { 'id' => '01' } }
  let(:method_2) { { 'id' => '02' } }
  let(:method_4) { { 'id' => '04' } }
  let(:method_6) { { 'id' => '06' } }
  let(:limit_1) { { 'metric_id' => '01', 'metric' => { 'type' => 'method' } } }
  let(:limit_2) { { 'metric_id' => '02', 'metric' => { 'type' => 'method' } } }
  let(:limit_3) { { 'metric_id' => '03', 'metric' => { 'type' => 'metric' } } }
  let(:pr_1) { { 'metric_id' => '01', 'metric' => { 'type' => 'method' } } }
  let(:pr_2) { { 'metric_id' => '04', 'metric' => { 'type' => 'method' } } }
  let(:pr_3) { { 'metric_id' => '05', 'metric' => { 'type' => 'metric' } } }
  let(:resource_limits) { [limit_1, limit_2, limit_3] }
  let(:resource_pricingrules) { [pr_1, pr_2, pr_3] }
  let(:service_methods) { [method_1, method_2, method_4, method_6] }
  let(:context) do
    {
      service_methods: service_methods,
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

    it 'method 01 from limits and pricingrules in plan methods' do
      expect(result[:plan_methods]).to include(method_1['id'] => method_1)
    end

    it 'method 02 from limits in plan methods' do
      expect(result[:plan_methods]).to include(method_2['id'] => method_2)
    end

    it 'metric 03 from limits not in plan methods' do
      expect(result[:plan_methods]).not_to include('03')
    end

    it 'method 04 from pricing_rules in plan methods' do
      expect(result[:plan_methods]).to include(method_4['id'] => method_4)
    end

    it 'metric 05 from pricingrules not in plan methods' do
      expect(result[:plan_methods]).not_to include('05')
    end

    it 'method 06 not in plan methods' do
      expect(result[:plan_methods]).not_to include(method_6['id'])
    end
  end
end
