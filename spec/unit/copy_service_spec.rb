require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  context '#run' do
    let(:source_service_id) { 100 }
    let(:target_service_id) { 200 }
    let(:source_system_name) { 'source_name' }
    let(:source_service_obj) { { 'id' => source_service_id, 'system_name' => source_system_name } }
    let(:target_service_obj) { { 'id' => target_service_id } }
    let(:source_remote) { double('source_remote') }
    let(:target_remote) { double('target_remote') }
    let(:arguments) { { 'service_id': source_service_id } }
    let(:options) do
      {
        'source': 'mysource',
        'destination': 'mydestination'
      }
    end
    let(:expected_create_params) do
      {
        'system_name' => source_system_name
      }
    end

    subject { described_class.new(options, arguments, nil) }

    before :each do
      # Remote stub
      expect(subject).to receive(:threescale_client).with('mysource').and_return(source_remote)
      expect(subject).to receive(:threescale_client).with('mydestination').and_return(target_remote)

      expect(source_remote).to receive(:show_service).with(source_service_id).and_return(source_service_obj)
      expect(target_remote).to receive(:create_service)
        .with(hash_including(expected_create_params)).and_return(target_service_obj)

      # Task stubs
      [
        ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
        ThreeScaleToolbox::Tasks::CopyMethodsTask,
        ThreeScaleToolbox::Tasks::CopyMetricsTask,
        ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
        ThreeScaleToolbox::Tasks::CopyLimitsTask,
        ThreeScaleToolbox::Tasks::DestroyMappingRulesTask,
        ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
        ThreeScaleToolbox::Tasks::CopyPoliciesTask,
        ThreeScaleToolbox::Tasks::CopyPricingRulesTask,
      ].each do |task_class|
        task = double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end
    end

    it 'all required tasks are run' do
      # Run
      expect { subject.run }.to output.to_stdout
    end

    context 'with target system name option' do
      let(:target_system_name) { 'target_name' }
      let(:options) do
        {
          'source': 'mysource',
          'destination': 'mydestination',
          'target_system_name': target_system_name
        }
      end
      let(:expected_create_params) do
        {
          'system_name' => target_system_name
        }
      end

      it 'target system_name is overridden' do
        # Run
        expect { subject.run }.to output.to_stdout
      end
    end
  end
end
