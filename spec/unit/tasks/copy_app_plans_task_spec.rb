require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Tasks::CopyApplicationPlansTask do
  context '#call' do
    let(:source) { double('source') }
    let(:target) { double('target') }
    2.times do |idx|
      let("plan_#{idx}".to_sym) do
        {
          'id' => idx,
          'name' => "plan_#{idx}",
          'state' => 'published',
          'default' => false,
          'created_at' => '2014-08-07T11:15:10+02:00',
          'updated_at' => '2014-08-07T11:15:13+02:00',
          'custom' => false,
          'system_name' => "plan_#{idx}",
          'links' => []
        }
      end
    end
    let(:custom_plan) do
      {
        'id' => 6666,
        'name' => 'custom_plan',
        'state' => 'published',
        'default' => false,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'custom' => true,
        'system_name' => 'custom_plan',
        'links' => []
      }
    end
    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:plans).and_return(source_plans)
      expect(target).to receive(:plans).and_return(target_plans)
    end

    context 'no plans to copy' do
      # missing plans is an empty set
      let(:source_plans) { [plan_0] }
      let(:target_plans) { [plan_0, plan_1] }

      it 'does not call create_application_plan method' do
        expect { subject.call }.to output(/target service missing 0 application plans/).to_stdout
      end
    end

    context 'one plan to be copied' do
      let(:source_plans) { [plan_0] }
      let(:target_plans) { [plan_1] }

      it 'call create_application_plan method' do
        expect(target).to receive(:create_application_plan).with(plan_0)
        expect { subject.call }.to output(/target service missing 1 application plans/).to_stdout
      end
    end

    context 'custom plans are not copied' do
      let(:source_plans) { [custom_plan] }
      let(:target_plans) { [plan_0] }

      it 'does not call create_application_plan method' do
        expect { subject.call }.to output(/skipping custom plan/).to_stdout
      end
    end
  end
end
