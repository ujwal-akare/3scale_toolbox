RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopySubcommand do
  let(:source_remote) { 'https://1234556@3scale-admin.source.example.com' }
  let(:target_remote) { 'https://1234556@3scale-admin.target.example.com' }
  let(:source_backend) { 'backend01' }
  let(:source_remote_obj) { instance_double(ThreeScale::API::Client, 'source_remote_obj') }
  let(:target_remote_obj) { instance_double(ThreeScale::API::Client, 'target_remote_obj') }
  let(:arguments) do
    {
      source_remote: source_remote,
      target_remote: target_remote,
      source_backend: source_backend
    }
  end
  let(:options) { { target_system_name: 'other_system_name' } }
  let(:expected_context) do
    {
      source_remote: source_remote_obj,
      target_remote: target_remote_obj,
      source_backend_ref: source_backend,
      option_target_system_name: 'other_system_name'
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
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask,
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMetricsTask,
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMethodsTask,
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMappingRulesTask
      ].each do |task_class|
        task = instance_double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).with(hash_including(expected_context)).and_return(task)
        expect(task).to receive(:call)
      end
    end

    it 'all required tasks are run' do
      # Run
      subject.run
    end
  end
end
