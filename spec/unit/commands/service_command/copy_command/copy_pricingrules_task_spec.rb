RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPricingRulesTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:source_plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:target_plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:target_plan_1) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:source_metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:target_metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric) }
    let(:source_metric_id) { 1 }
    let(:target_metric_id) { 2 }
    let(:pricing_rule_0) do
      {
        'id' => 1,
        'name' => 'pr_1',
        'cost_per_unit' => '1.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => source_metric_id
      }
    end
    let(:pricing_rule_1) do
      {
        'id' => 1,
        'name' => 'pr_1',
        'cost_per_unit' => '1.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => target_metric_id
      }
    end
    let(:pricing_rule_2) do
      {
        'id' => 2,
        'name' => 'pr_2',
        'cost_per_unit' => '2.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => target_metric_id + 1,
      }
    end
    let(:source_plans) { [] }
    let(:source_metrics) { [] }
    let(:target_metrics) { [] }
    let(:source_pricingrules) { [] }
    let(:target_pricingrules) { [] }

    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:plans).and_return(source_plans)
      expect(target).to receive(:plans).and_return(target_plans)
      allow(source_plan_0).to receive(:id).and_return(1)
      allow(source_plan_0).to receive(:pricing_rules).and_return(source_pricingrules)
      allow(source_plan_0).to receive(:system_name).and_return('plan_0')
      allow(target_plan_0).to receive(:id).and_return(1)
      allow(target_plan_0).to receive(:system_name).and_return('plan_0')
      allow(target_plan_0).to receive(:pricing_rules).and_return(target_pricingrules)
      allow(target_plan_1).to receive(:id).and_return(2)
      allow(target_plan_1).to receive(:system_name).and_return('plan_1')
      allow(target_plan_1).to receive(:pricing_rules).and_return(target_pricingrules)
      allow(source_metric_0).to receive(:id).and_return(source_metric_id)
      allow(source_metric_0).to receive(:system_name).and_return('metric_0')
      allow(target_metric_0).to receive(:id).and_return(target_metric_id)
      allow(target_metric_0).to receive(:system_name).and_return('metric_0')
      allow(source).to receive(:metrics).and_return(source_metrics)
      allow(source).to receive(:methods).and_return([])
      allow(target).to receive(:metrics).and_return(target_metrics)
      allow(target).to receive(:methods).and_return([])
    end

    context 'no application plan match' do
      # mapped plans is empty set
      let(:target_plans) { [target_plan_1] }
      let(:source_plans) { [source_plan_0] }

      it 'does not create limit' do
        subject.call
      end
    end

    context 'missing pricingrules is empty' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      # missing pricining rules set is empty
      let(:source_metrics) { [source_metric_0] }
      let(:target_metrics) { [target_metric_0] }
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [pricing_rule_1] }

      # missing_pricingrules is an empty set
      it 'does not call create_pricingrule method' do
        expect { subject.call }.to output(/Missing 0 pricing rules/).to_stdout
      end
    end

    context '1 pricing rule missing' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [] }
      let(:source_metrics) { [source_metric_0] }
      let(:target_metrics) { [target_metric_0] }

      it 'call create_pricingrule method' do
        expect(target_plan_0).to receive(:create_pricing_rule).with(target_metric_0.id, pricing_rule_0)
        expect { subject.call }.to output(/Missing 1 pricing rules/).to_stdout
      end
    end

    context '1 pricing rule missing because rules do not match' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [pricing_rule_2] }
      let(:source_metrics) { [source_metric_0] }
      let(:target_metrics) { [target_metric_0] }

      it 'call create_pricingrule method' do
        expect(target_plan_0).to receive(:create_pricing_rule).with(target_metric_0.id, pricing_rule_0)
        expect { subject.call }.to output(/Missing 1 pricing rules/).to_stdout
      end
    end
  end
end
