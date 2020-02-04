RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopySubcommand do
  context '#run' do
    let(:source_system_name) { 'source_name' }
    let(:arguments) { { 'source_service': source_system_name } }
    let(:options) { { 'source': 'mysource', 'destination': 'mydestination' } }
    let(:source_remote) { instance_double(ThreeScale::API::Client, 'source_remote') }
    let(:target_remote) { instance_double(ThreeScale::API::Client, 'target_remote') }

    subject { described_class.new(options, arguments, nil) }

    before :each do
      # Remote stub
      expect(subject).to receive(:threescale_client).with('mysource').and_return(source_remote)
      expect(subject).to receive(:threescale_client).with('mydestination').and_return(target_remote)
    end

    it 'default options' do
      # Task stubs
      [
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CreateOrUpdateTargetServiceTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyServiceProxyTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMethodsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyApplicationPlansTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyLimitsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPoliciesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPricingRulesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyActiveDocsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::BumpProxyVersionTask,
      ].each do |task_class|
        task = double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end

      # Run
      subject.run
    end

    context 'when rules only option set' do
      let(:options) do
        { 'source': 'mysource', 'destination': 'mydestination', 'rules-only': true }
      end

      it 'only mapping rules tasks are run' do
        # Task stubs
        [
          ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask,
          ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask,
          ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::BumpProxyVersionTask,
        ].each do |task_class|
          task = double(task_class.to_s)
          task_class_obj = class_double(task_class).as_stubbed_const
          expect(task_class_obj).to receive(:new).and_return(task)
          expect(task).to receive(:call)
        end

        # Run
        subject.run
      end
    end
  end
end
