RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyLimitsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:source_plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:target_plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:target_plan_1) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
    let(:limit_0) { instance_double(ThreeScaleToolbox::Entities::Limit) }
    let(:metric_id_1) { 1 }
    let(:metric_id_2) { 2 }
    let(:limit_0_attrs) do
      { # limit for metric_0
        'id' => 1,
        'period' => 'year',
        'value' => 10_000,
        'metric_id' => metric_id_1,
      }
    end
    let(:limit_1) { instance_double(ThreeScaleToolbox::Entities::Limit) }
    let(:limit_1_attrs) do
      { # limit for metric_1
        'id' => 1,
        'period' => 'year',
        'value' => 10_000,
        'metric_id' => metric_id_2,
      }
    end
    let(:source_plans) { [] }
    let(:source_limits) { [] }
    let(:target_limits) { [] }
    let(:metrics_mapping) { { metric_id_1 => metric_id_2 } }

    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:plans).and_return(source_plans)
      expect(target).to receive(:plans).and_return(target_plans)
      allow(source_plan_0).to receive(:id).and_return(1)
      allow(source_plan_0).to receive(:limits).and_return(source_limits)
      allow(source_plan_0).to receive(:system_name).and_return('plan_0')
      allow(target_plan_0).to receive(:id).and_return(1)
      allow(target_plan_0).to receive(:system_name).and_return('plan_0')
      allow(target_plan_0).to receive(:limits).and_return(target_limits)
      allow(target_plan_1).to receive(:id).and_return(2)
      allow(target_plan_1).to receive(:system_name).and_return('plan_1')
      allow(target_plan_1).to receive(:limits).and_return(target_limits)
      allow(limit_0).to receive(:attrs).and_return(limit_0_attrs)
      allow(limit_0).to receive(:period).and_return(limit_0_attrs.fetch('period'))
      allow(limit_0).to receive(:value).and_return(limit_0_attrs.fetch('value'))
      allow(limit_0).to receive(:metric_id).and_return(limit_0_attrs.fetch('metric_id'))
      allow(limit_1).to receive(:attrs).and_return(limit_1_attrs)
      allow(limit_1).to receive(:period).and_return(limit_1_attrs.fetch('period'))
      allow(limit_1).to receive(:value).and_return(limit_1_attrs.fetch('value'))
      allow(limit_1).to receive(:metric_id).and_return(limit_1_attrs.fetch('metric_id'))
      allow(source).to receive(:metrics_mapping).and_return(metrics_mapping)
    end

    context 'no application plan match' do
      # mapped plans is empty set
      let(:target_plans) { [target_plan_1] }
      let(:source_plans) { [source_plan_0] }

      it 'does not create limit' do
        subject.call
      end
    end

    context 'missing limits is empty' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      # missing limits set is empty
      let(:source_limits) { [limit_0] }
      let(:target_limits) { [limit_1] }

      it 'does not create limits' do
        expect { subject.call }.to output(/Missing 0 plan limits/).to_stdout
      end
    end

    context '1 limit missing' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      let(:source_limits) { [limit_0] }
      let(:target_limits) { [] }

      it 'creates one limit' do
        expect(target_plan_0).to receive(:create_limit).with(metric_id_2, limit_0.attrs)
        expect { subject.call }.to output(/Missing 1 plan limits/).to_stdout
      end
    end

    context '1 limit missing because limits do not match' do
      let(:target_plans) { [target_plan_0] }
      let(:source_plans) { [source_plan_0] }
      let(:source_limits) { [limit_0] }
      let(:custom_limit) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:custom_limit_attrs) do
        {
          'id' => 123,
          'period' => 'year',
          'value' => 10_000,
          'metric_id' => metric_id_2 + 1,
        }
      end
      let(:target_limits) { [custom_limit] }

      before :example do
        allow(custom_limit).to receive(:attrs).and_return(custom_limit_attrs)
        allow(custom_limit).to receive(:period).and_return(custom_limit_attrs.fetch('period'))
        allow(custom_limit).to receive(:value).and_return(custom_limit_attrs.fetch('value'))
        allow(custom_limit).to receive(:metric_id).and_return(custom_limit_attrs.fetch('metric_id'))
      end

      it 'creates one limit' do
        expect(target_plan_0).to receive(:create_limit).with(metric_id_2, limit_0.attrs)
        expect { subject.call }.to output(/Missing 1 plan limits/).to_stdout
      end
    end
  end
end
