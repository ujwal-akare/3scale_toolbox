RSpec.describe ThreeScaleToolbox::Tasks::CopyPricingRulesTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:source_remote) { instance_double('ThreeScale::API::Client', 'source_remote') }
    let(:target_remote) { instance_double('ThreeScale::API::Client', 'target_remote') }
    let(:plan_0) { { 'id' => 0, 'name' => 'plan_0', 'system_name' => 'plan_0' } }
    let(:plan_1) { { 'id' => 1, 'name' => 'plan_1', 'system_name' => 'plan_1' } }
    let(:metric_hits) { { 'id' => 0, 'name' => 'hits', 'system_name' => 'hits' } }
    let(:metric_0) { { 'id' => 1, 'name' => 'metric_0', 'system_name' => 'metric_0' } }
    let(:metric_1) { { 'id' => 2, 'name' => 'metric_0', 'system_name' => 'metric_0' } }
    let(:pricing_rule_0) do
      {
        'id' => 1,
        'name' => 'pr_1',
        'cost_per_unit' => '1.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => 1
      }
    end
    let(:pricing_rule_1) do
      {
        'id' => 1,
        'name' => 'pr_2',
        'cost_per_unit' => '1.0',
        'min' => 1,
        'max' => 1000,
        'metric_id' => 3
      }
    end
    let(:source_plans) { [plan_0] }
    let(:target_plans) { [plan_0] }

    subject { described_class.new(source: source, target: target) }

    before :each do
      allow(source).to receive(:remote).and_return(source_remote)
      allow(target).to receive(:remote).and_return(target_remote)
      expect(source).to receive(:plans).and_return(source_plans)
      expect(target).to receive(:plans).and_return(target_plans)
    end

    context 'no application plan match' do
      # missing plans is empty set
      let(:target_plans) { [plan_1] }

      it 'does not call create_application_plan_limit method' do
        subject.call
      end
    end

    context 'application plans match' do
      before :each do
        expect(source).to receive(:metrics).and_return([metric_0])
        expect(source).to receive(:hits).and_return(metric_hits)
        expect(source).to receive(:methods).and_return([])
        expect(target).to receive(:metrics).and_return([metric_1])
        expect(target).to receive(:hits).and_return(metric_hits)
        expect(target).to receive(:methods).and_return([])
        expect(source_remote).to receive(:list_pricingrules_per_application_plan).and_return(source_pricingrules)
        expect(target_remote).to receive(:list_pricingrules_per_application_plan).and_return(target_pricingrules)
      end

      context 'no pricingrules match' do
        let(:source_pricingrules) { [] }
        let(:target_pricingrules) { [] }

        # missing_pricingrules is an empty set
        it 'does not call create_pricingrule method' do
          expect { subject.call }.to output(/Missing 0 pricing rules/).to_stdout
        end
      end

      context 'target pricingrules empty' do
        let(:source_pricingrules) { [pricing_rule_0] }
        let(:target_pricingrules) { [] }

        it 'call create_pricingrule method' do
          expect(target_remote).to receive(:create_pricingrule).with(plan_0['id'],
                                                                     metric_1['id'],
                                                                     pricing_rule_0)
          expect { subject.call }.to output(/Missing 1 pricing rules/).to_stdout
        end
      end

      context 'pricingrules from diff metrics' do
        let(:source_pricingrules) { [pricing_rule_0] }
        let(:target_pricingrules) { [pricing_rule_1] } # pricing_rule_1 does not belong to same metric

        it 'does not call create_pricingrule method' do
          expect(target_remote).to receive(:create_pricingrule).with(plan_0['id'],
                                                                     metric_1['id'],
                                                                     pricing_rule_0)
          expect { subject.call }.to output(/Missing 1 pricing rules/).to_stdout
        end
      end
    end
  end
end
