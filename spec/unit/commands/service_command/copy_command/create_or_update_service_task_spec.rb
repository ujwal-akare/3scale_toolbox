RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CreateOrUpdateTargetServiceTask do
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:source_ref) { 'source_01' }
  let(:target_ref) { 'target_01' }
  let(:source_remote) { instance_double(ThreeScale::API::Client, 'source_remote') }
  let(:target_remote) { instance_double(ThreeScale::API::Client, 'target_remote') }
  let(:source_service) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_service') }
  let(:source_attrs) { { 'id' => 1, 'system_name': source_ref } }
  let(:target_attrs) { { 'id' => 2, 'system_name': target_ref } }
  let(:target_service) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_service') }
  let(:context) do
    {
      option_target_system_name: target_ref,
      source_service_ref: source_ref,
      source_remote: source_remote,
      target_remote: target_remote
    }
  end
  subject { described_class.new(context) }

  before :each do
    allow(source_service).to receive(:id).and_return(1)
    allow(target_service).to receive(:id).and_return(2)
    allow(source_service).to receive(:attrs).and_return(source_attrs)
    allow(target_service).to receive(:attrs).and_return(target_attrs)
    expect(service_class).to receive(:find)
      .with(remote: source_remote, ref: source_ref)
      .and_return(source_service)
  end

  context 'target does not exists' do
    before :each do
      expect(service_class).to receive(:find).with(remote: target_remote, ref: target_ref)
                                             .and_return(nil)
    end

    it 'then new service created' do
      expect(service_class).to receive(:create)
        .with(remote: target_remote, service_params: hash_including('system_name' => target_ref))
        .and_return(target_service)
      subject.call
    end
  end

  context 'target exists' do
    before :each do
      expect(service_class).to receive(:find)
        .with(remote: target_remote, ref: target_ref)
        .and_return(target_service)
    end

    it 'then backend updated' do
      expect(target_service).to receive(:update).with(hash_including('system_name' => target_ref))
      subject.call
    end
  end
end
