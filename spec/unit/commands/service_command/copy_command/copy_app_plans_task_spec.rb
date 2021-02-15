RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyApplicationPlansTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan, 'plan0') }
    let(:plan_0_attrs) { { 'system_name' => 'plan_0', 'friendly_name' => 'plan_0' } }
    let(:plan_1) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan, 'plan1') }
    let(:custom_plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan, 'custom_plan') }
    let(:custom_plan_attrs) { { 'system_name' => 'custom_plan', 'custom' => true } }
    let(:task_context) { { source: source, target: target, logger: Logger.new('/dev/null') } }

    subject { described_class.new(task_context) }

    before :each do
      expect(source).to receive(:plans).and_return(source_plans)
      expect(target).to receive(:plans).and_return(target_plans)
      allow(plan_0).to receive(:system_name).and_return(plan_0_attrs.fetch('system_name'))
      allow(plan_0).to receive(:attrs).and_return(plan_0_attrs)
      allow(plan_0).to receive(:custom).and_return(false)
      allow(plan_1).to receive(:system_name).and_return('plan_1')
      allow(plan_1).to receive(:custom).and_return(false)
      allow(custom_plan).to receive(:system_name).and_return(custom_plan_attrs['custom'])
      allow(custom_plan).to receive(:attrs).and_return(custom_plan_attrs)
      allow(custom_plan).to receive(:custom).and_return(true)
    end

    context 'no plans to copy' do
      # missing plans is an empty set
      let(:source_plans) { [plan_0] }
      let(:target_plans) { [plan_0, plan_1] }

      it 'does not call create_application_plan method' do
        subject.call

        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_application_plans_created')
        expect(task_context.dig(:report, 'missing_application_plans_created')).to eq(0)
      end
    end

    context 'one plan to be copied' do
      let(:source_plans) { [plan_0] }
      let(:target_plans) { [plan_1] }

      it 'call create_application_plan method' do
        expect(ThreeScaleToolbox::Entities::ApplicationPlan).to receive(:create).with(hash_including(service: target, plan_attrs: plan_0_attrs))

        subject.call

        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_application_plans_created')
        expect(task_context.dig(:report, 'missing_application_plans_created')).to eq(1)
      end
    end

    context 'custom plans are not copied' do
      let(:source_plans) { [custom_plan] }
      let(:target_plans) { [plan_0] }

      it 'does not call create_application_plan method' do
        subject.call

        expect(task_context).to include(:report)
        expect(task_context.fetch(:report)).to include('missing_application_plans_created')
        expect(task_context.dig(:report, 'missing_application_plans_created')).to eq(0)
      end
    end
  end
end
