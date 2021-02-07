RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ReadPlanMethods do
  let(:method_1) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_2) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_4) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_6) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:limit_1) { { 'metric_id' => 1, 'metric' => { 'type' => 'method' } } }
  let(:limit_2) { { 'metric_id' => 2, 'metric' => { 'type' => 'method' } } }
  let(:limit_3) { { 'metric_id' => 3, 'metric' => { 'type' => 'metric' } } }
  let(:pr_1) { { 'metric_id' => 1, 'metric' => { 'type' => 'method' } } }
  let(:pr_2) { { 'metric_id' => 4, 'metric' => { 'type' => 'method' } } }
  let(:pr_3) { { 'metric_id' => 5, 'metric' => { 'type' => 'metric' } } }
  let(:resource_limits) { [limit_1, limit_2, limit_3] }
  let(:resource_pricingrules) { [pr_1, pr_2, pr_3] }
  let(:service_methods) { [method_1, method_2, method_4, method_6] }
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
      allow(method_1).to receive(:attrs).and_return({'system_name' => 'method 1'})
      allow(method_2).to receive(:id).and_return(2)
      allow(method_2).to receive(:attrs).and_return({'system_name' => 'method 2'})
      allow(method_4).to receive(:id).and_return(4)
      allow(method_4).to receive(:attrs).and_return({'system_name' => 'method 4'})
      allow(method_6).to receive(:id).and_return(6)
      allow(method_6).to receive(:attrs).and_return({'system_name' => 'method 6'})
      expect(service_class).to receive(:find).and_return(service)
      allow(service).to receive(:hits).and_return({'id' => 1})
      allow(service).to receive(:methods).and_return(service_methods)

      subject.call
    end

    it 'method 01 from limits and pricingrules in plan methods' do
      expect(result[:plan_methods]).to include(method_1.id => method_1.attrs)
    end

    it 'method 02 from limits in plan methods' do
      expect(result[:plan_methods]).to include(method_2.id => method_2.attrs)
    end

    it 'metric 03 from limits not in plan methods' do
      expect(result[:plan_methods]).not_to include(3)
    end

    it 'method 04 from pricing_rules in plan methods' do
      expect(result[:plan_methods]).to include(method_4.id => method_4.attrs)
    end

    it 'metric 05 from pricingrules not in plan methods' do
      expect(result[:plan_methods]).not_to include(5)
    end

    it 'method 06 not in plan methods' do
      expect(result[:plan_methods]).not_to include(method_6.id)
    end
  end
end
