RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::ExportSubcommand do
  let(:remote) { 'https://1234556@3scale-admin.source.example.com' }
  let(:filename) { '/path/to/file' }
  let(:file_class) { class_double(File).as_stubbed_const }
  let(:remote_obj) { instance_double(ThreeScale::API::Client, 'remote_obj') }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:file_like_object) { instance_double(File) }
  let(:arguments) do
    {
      service_system_name: 'someservice',
      remote: remote,
      plan_system_name: 'someplan'
    }
  end
  let(:options) { { file: filename } }
  subject { described_class.new(options, arguments, nil) }

  before :each do
    expect(subject).to receive(:threescale_client).with(remote).and_return(remote_obj)
    expect(service_class).to receive(:find).with(remote: remote_obj, ref: 'someservice').and_return(service)
    expect(plan_class).to receive(:find).with(service: service, ref: 'someplan').and_return(plan)
    expect(file_class).to receive(:open).with(filename, 'w').and_return(file_like_object)
    expect(file_like_object).to receive(:close)
  end

  context '#run' do
    let(:plan_hash) { { 'attr1' => 'val1', 'attr2' => 'val2' } }

    it 'plan exported to file' do
      expect(plan).to receive(:to_hash).and_return(plan_hash)
      expect(file_like_object).to receive(:write) do |content|
        content_obj = YAML.load(content)
        expect(content_obj).to include('attr1')
        expect(content_obj).to include('attr2')
        expect(content_obj).to include('created_at')
        expect(content_obj).to include('toolbox_version' => ThreeScaleToolbox::VERSION)
      end

      # Run
      subject.run
    end

    context 'application plan does not exist' do
      let(:plan) { nil }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /Application plan someplan does not exist/)
      end
    end
  end
end
