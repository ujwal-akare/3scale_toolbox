RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::CopyCommand::CopyBackendsTask do
  let(:source) { instance_double(ThreeScaleToolbox::Entities::Service, 'source')  }
  let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target')  }
  let(:source_remote) { instance_double(ThreeScale::API::Client, 'source_remote') }
  let(:target_remote) { instance_double(ThreeScale::API::Client, 'target_remote') }
  let(:backend_usage_01) { instance_double(ThreeScaleToolbox::Entities::BackendUsage)  }
  let(:source_backend_id) { 1 }
  let(:target_backend_id) { 2 }
  let(:backend_01_attrs) { { 'system_name' => 'backend_01' } }
  let(:backend_usage_list) { [backend_usage_01] }
  let(:context) do
    {
      source: source,
      target: target,
      source_remote: source_remote,
      target_remote: target_remote
    }
  end
  subject { described_class.new(context) }

  context '#call' do
    before :each do
      expect(source).to receive(:backend_usage_list).and_return(backend_usage_list)
      expect(backend_usage_01).to receive(:backend_id).and_return(source_backend_id)
      expect(backend_usage_01).to receive(:path).and_return('/v1')

      create_task = double('create task')
      allow(ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask).to receive(:new) do |backend_context|
        backend_context[:target_backend] = ThreeScaleToolbox::Entities::Backend.new(
          id: target_backend_id,
          remote: target_remote
        )
        create_task
      end
      expect(create_task).to receive(:call)
      # Task stubs
      [
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMetricsTask,
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMethodsTask,
        ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMappingRulesTask
      ].each do |task_class|
        task = instance_double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end
      backend_usage_class_obj = class_double(ThreeScaleToolbox::Entities::BackendUsage).as_stubbed_const
      expect(backend_usage_class_obj).to receive(:create).with(
        product: target,
        attrs: {
          'backend_api_id' => target_backend_id,
          'path' => '/v1'
        }
      )
    end

    it do
      expect { subject.call }.to output.to_stdout
    end
  end
end
