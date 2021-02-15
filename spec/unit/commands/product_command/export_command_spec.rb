RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::ExportSubcommand do
  let(:remote) { 'https://1234556@3scale-admin.source.example.com' }
  let(:product_ref) { 'product_01' }
  let(:remote_obj) { instance_double(ThreeScale::API::Client, 'remote_obj') }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:backend_class) { class_double('ThreeScaleToolbox::Entities::Backend').as_stubbed_const }
  let(:file_class) { class_double(File).as_stubbed_const }
  let(:arguments) { { product_ref: product_ref, remote: remote } }
  let(:filename) { '/path/to/file' }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend) }
  let(:backend_usage) { instance_double(ThreeScaleToolbox::Entities::BackendUsage) }
  let(:file_like_object) { instance_double(File) }
  let(:backend_list) { [backend_usage] }
  let(:product_cr) { { 'productattr' => 'productvalue' } }
  let(:backend_cr) { { 'backendattr' => 'backendvalue' } }
  let(:options) { { file: filename } }
  subject { described_class.new(options, arguments, nil) }

  before :each do
    expect(subject).to receive(:threescale_client).with(remote).and_return(remote_obj)
    expect(service_class).to receive(:find).with(remote: remote_obj, ref: product_ref).and_return(service)
    expect(service).to receive(:to_cr).and_return(product_cr)
    expect(service).to receive(:backend_usage_list).and_return(backend_list)
    allow(backend_usage).to receive(:backend_id).and_return(1)
    allow(backend_class).to receive(:new).with(id: 1, remote: remote_obj).and_return(backend)
    allow(backend).to receive(:to_cr).and_return(backend_cr)
    allow(file_class).to receive(:open).with(filename, 'w').and_return(file_like_object)
    allow(file_like_object).to receive(:close)
  end

  context '#run' do
    it 'product included' do
      expect(file_like_object).to receive(:write) do |content|
        content_obj = YAML.load(content)
        expect(content_obj).to include('items')
        expect(content_obj.fetch('items')).to include(product_cr)
      end
      # Run
      subject.run
    end

    it 'backend included' do
      expect(file_like_object).to receive(:write) do |content|
        content_obj = YAML.load(content)
        expect(content_obj).to include('items')
        expect(content_obj.fetch('items')).to include(backend_cr)
      end
      # Run
      subject.run
    end
  end
end
