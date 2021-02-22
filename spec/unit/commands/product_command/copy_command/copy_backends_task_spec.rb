RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::CopyCommand::CopyBackendsTask do
  let(:source) { instance_double(ThreeScaleToolbox::Entities::Service, 'source')  }
  let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target')  }
  let(:source_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_backend')  }
  let(:target_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_backend')  }
  let(:source_remote) { instance_double(ThreeScale::API::Client, 'source_remote') }
  let(:target_remote) { instance_double(ThreeScale::API::Client, 'target_remote') }
  let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
  let(:backend_usage_01) { instance_double(ThreeScaleToolbox::Entities::BackendUsage)  }
  let(:source_backend_id) { 1 }
  let(:target_backend_id) { 2 }
  let(:backend_usage_list) { [backend_usage_01] }
  let(:task_context) do
    {
      source: source,
      target: target,
      source_remote: source_remote,
      target_remote: target_remote,
      report: {},
      logger: Logger.new('/dev/null')
    }
  end
  subject { described_class.new(task_context) }

  context '#call' do
    before :each do
      allow(backend_usage_01).to receive(:backend_id).and_return(source_backend_id)
      allow(backend_usage_01).to receive(:path).and_return('/v1')
      allow(source).to receive(:backend_usage_list).and_return(backend_usage_list)
      allow(source_backend).to receive(:id).and_return(source_backend_id)
      allow(target_backend).to receive(:id).and_return(target_backend_id)
      allow(target_backend).to receive(:system_name).and_return('backend_01')
      expect(backend_class).to receive(:new).with(id: source_backend_id, remote: source_remote).and_return(source_backend)

      create_task = double('create task')
      expect(ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask).to receive(:new) do |backend_context|
        backend_context[:target_backend] = target_backend
        backend_context[:report] = {}

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
      subject.call
    end
  end
end
