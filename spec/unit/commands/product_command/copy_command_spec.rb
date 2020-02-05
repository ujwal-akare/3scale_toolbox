RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::CopySubcommand do
  let(:source_remote) { 'https://1234556@3scale-admin.source.example.com' }
  let(:target_remote) { 'https://1234556@3scale-admin.target.example.com' }
  let(:source_product) { 'product_01' }
  let(:source_remote_obj) { instance_double(ThreeScale::API::Client, 'source_remote_obj') }
  let(:target_remote_obj) { instance_double(ThreeScale::API::Client, 'target_remote_obj') }
  let(:arguments) { { source_product: source_product } }
  let(:options) do
    {
      'target-system-name': 'other_system_name',
      source: source_remote,
      destination: target_remote
    }
  end
  subject { described_class.new(options, arguments, nil) }

  before :each do
    expect(subject).to receive(:threescale_client).with(source_remote).and_return(source_remote_obj)
    expect(subject).to receive(:threescale_client).with(target_remote).and_return(target_remote_obj)
  end

  context '#run' do
    before :each do
      # Task stubs
      [
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CreateOrUpdateTargetServiceTask,
        ThreeScaleToolbox::Commands::ProductCommand::CopyCommand::DeleteExistingTargetBackendUsagesTask,
        ThreeScaleToolbox::Commands::ProductCommand::CopyCommand::CopyBackendsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyServiceProxyTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMethodsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyApplicationPlansTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyLimitsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPoliciesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPricingRulesTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyActiveDocsTask,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::BumpProxyVersionTask
      ].each do |task_class|
        task = instance_double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end
    end

    it 'all required tasks are run' do
      # Run
      subject.run
    end
  end
end
