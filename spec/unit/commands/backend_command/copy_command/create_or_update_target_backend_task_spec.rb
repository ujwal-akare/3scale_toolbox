RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask do
  let(:source_remote) { instance_double(ThreeScale::API::Client, 'source_remote') }
  let(:target_remote) { instance_double(ThreeScale::API::Client, 'target_remote') }
  let(:source_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_backend') }
  let(:target_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_backend') }
  let(:source_ref) { 'source_backend_01' }
  let(:target_ref) { 'target_backend_01' }
  let(:source_attrs) { { 'id' => 1, 'system_name': source_ref } }
  let(:target_attrs) { { 'id' => 2, 'system_name': target_ref } }
  let(:task_context)  do
    {
      option_target_system_name: target_ref,
      source_backend_ref: source_ref,
      source_remote: source_remote,
      target_remote: target_remote,
      logger: Logger.new('/dev/null')
    }
  end
  let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
  subject { described_class.new(task_context) }

  context '#run' do
    before :each do
      allow(source_backend).to receive(:id).and_return(1)
      allow(target_backend).to receive(:id).and_return(2)
      allow(source_backend).to receive(:attrs).and_return(source_attrs)
      allow(target_backend).to receive(:attrs).and_return(target_attrs)
      allow(source_backend).to receive(:system_name).and_return(source_ref)
      allow(target_backend).to receive(:system_name).and_return(target_ref)
      expect(backend_class).to receive(:find)
        .with(remote: source_remote, ref: source_ref)
        .and_return(source_backend)
    end

    context 'backend does not exists' do
      before :each do
        expect(backend_class).to receive(:find)
          .with(remote: target_remote, ref: target_ref)
          .and_return(nil)
      end

      it 'then new backend created' do
        expect(backend_class).to receive(:create)
          .with(remote: target_remote, attrs: hash_including('system_name' => target_ref))
          .and_return(target_backend)
        subject.run
      end
    end

    context 'backend exists' do
      before :each do
        expect(backend_class).to receive(:find)
          .with(remote: target_remote, ref: target_ref)
          .and_return(target_backend)
      end

      it 'then backend updated' do
        expect(target_backend).to receive(:update).with(hash_including('system_name' => target_ref))
        subject.run
      end
    end
  end
end
