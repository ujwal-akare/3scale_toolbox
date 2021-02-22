RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPricingRulesTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:source_plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:target_plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:target_plan_1) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:source_metric_id) { 1 }
    let(:target_metric_id) { 2 }
    let(:pricing_rule_0) { instance_double(ThreeScaleToolbox::Entities::PricingRule) }
    let(:pricing_rule_0_attrs) do
      {
        'id' => 1,
        'name' => 'pr_1',
        'cost_per_unit' => '1.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => source_metric_id
      }
    end
    let(:pricing_rule_1) { instance_double(ThreeScaleToolbox::Entities::PricingRule) }
    let(:pricing_rule_1_attrs) do
      {
        'id' => 1,
        'name' => 'pr_1',
        'cost_per_unit' => '1.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => target_metric_id
      }
    end
    let(:pricing_rule_2) { instance_double(ThreeScaleToolbox::Entities::PricingRule) }
    let(:pricing_rule_2_attrs) do
      {
        'id' => 2,
        'name' => 'pr_2',
        'cost_per_unit' => '2.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => target_metric_id + 1,
      }
    end
    let(:metrics_mapping) { { source_metric_id => target_metric_id } }
    let(:source_plans) { [] }
    let(:source_pricingrules) { [] }
    let(:target_pricingrules) { [] }

    let(:task_context) { { source: source, target: target, logger: Logger.new('/dev/null') } }

    subject { described_class.new(task_context) }

    before :each do
      allow(source).to receive(:metrics_mapping).and_return(metrics_mapping)
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
      allow(pricing_rule_0).to receive(:attrs).and_return(pricing_rule_0_attrs)
      allow(pricing_rule_1).to receive(:attrs).and_return(pricing_rule_1_attrs)
      allow(pricing_rule_2).to receive(:attrs).and_return(pricing_rule_2_attrs)
      %w[cost_per_unit metric_id min max].each do |attr|
        allow(pricing_rule_0).to receive(attr.to_sym).and_return(pricing_rule_0_attrs.fetch(attr))
        allow(pricing_rule_1).to receive(attr.to_sym).and_return(pricing_rule_1_attrs.fetch(attr))
        allow(pricing_rule_2).to receive(attr.to_sym).and_return(pricing_rule_2_attrs.fetch(attr))
      end
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
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [pricing_rule_1] }

      # missing_pricingrules is an empty set
      it 'does not call create_pricingrule method' do
        subject.call

        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('application_plans')
        expect(task_context.dig(:report, 'application_plans')).to include(target_plan_0.system_name)
        expect(task_context.dig(:report, 'application_plans', target_plan_0.system_name, 'missing_pricing_rules_created')).to eq(0)
      end
    end

    context '1 pricing rule missing' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [] }

      it 'call create_pricingrule method' do
        expect(target_plan_0).to receive(:create_pricing_rule).with(target_metric_id, pricing_rule_0.attrs)

        subject.call

        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('application_plans')
        expect(task_context.dig(:report, 'application_plans')).to include(target_plan_0.system_name)
        expect(task_context.dig(:report, 'application_plans', target_plan_0.system_name, 'missing_pricing_rules_created')).to eq(1)
      end
    end

    context '1 pricing rule missing because rules do not match' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [pricing_rule_2] }

      it 'call create_pricingrule method' do
        expect(target_plan_0).to receive(:create_pricing_rule).with(target_metric_id, pricing_rule_0.attrs)

        subject.call

        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('application_plans')
        expect(task_context.dig(:report, 'application_plans')).to include(target_plan_0.system_name)
        expect(task_context.dig(:report, 'application_plans', target_plan_0.system_name, 'missing_pricing_rules_created')).to eq(1)
      end
    end
  end
end
