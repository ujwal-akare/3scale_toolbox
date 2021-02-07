RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanMetrics do
  let(:method_1) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_2) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:metric_3) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:method_4) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:metric_5) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:method_6) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:limit_1) { { 'metric_id' => method_1.id, 'metric' => { 'type' => 'method' } } }
  let(:limit_2) { { 'metric_id' => method_2.id, 'metric' => { 'type' => 'method' } } }
  let(:limit_3) { { 'metric_id' => metric_3.id, 'metric' => { 'type' => 'metric' } } }
  let(:pr_1) { { 'metric_id' => method_1.id, 'metric' => { 'type' => 'method' } } }
  let(:pr_2) { { 'metric_id' => method_4.id, 'metric' => { 'type' => 'method' } } }
  let(:pr_3) { { 'metric_id' => metric_5.id, 'metric' => { 'type' => 'metric' } } }
  let(:resource_limits) { [limit_1, limit_2, limit_3] }
  let(:resource_pricingrules) { [pr_1, pr_2, pr_3] }
  let(:service_metrics) { [method_1, method_2, metric_3, method_4, metric_5, method_6] }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:context) do
    {
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
      allow(method_1).to receive(:id).and_return(1)
      allow(method_2).to receive(:id).and_return(2)
      allow(metric_3).to receive(:id).and_return(3)
      allow(metric_3).to receive(:attrs).and_return({'system_name' => 'metric 3'})
      allow(method_4).to receive(:id).and_return(4)
      allow(metric_5).to receive(:id).and_return(5)
      allow(metric_5).to receive(:attrs).and_return({'system_name' => 'metric 5'})
      allow(method_6).to receive(:id).and_return(6)
      expect(service_class).to receive(:find).and_return(service)
      allow(service).to receive(:hits).and_return({'id' => 1})
      allow(service).to receive(:metrics).and_return(service_metrics)

      subject.call
    end

    it 'method 01 from limits and pricingrules not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_1.id)
    end

    it 'method 02 from limits not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_2.id)
    end

    it 'metric 03 from limits in plan metrics' do
      expect(result[:plan_metrics]).to include(metric_3.id => metric_3.attrs)
    end

    it 'method 04 from pricing_rules not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_4.id)
    end

    it 'metric 05 from pricingrules in plan metrics' do
      expect(result[:plan_metrics]).to include(metric_5.id => metric_5.attrs)
    end

    it 'method 06 not in plan metrics' do
      expect(result[:plan_metrics]).not_to include(method_6.id)
    end
  end
end
