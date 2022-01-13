RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::OpenAPISubcommand do
  include_context :temp_dir
  include_context :resources

  let(:import_backend_step_class) { class_double(ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ImportBackendStep).as_stubbed_const }
  let(:import_product_step_class) { class_double(ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ImportProductStep).as_stubbed_const }
  let(:json_printer_class) { class_double(ThreeScaleToolbox::CLI::JsonPrinter).as_stubbed_const }
  let(:import_backend_step) { instance_double(import_backend_step_class) }
  let(:import_product_step) { instance_double(import_product_step_class) }
  let(:arguments) { { 'openapi_resource': oas_resource } }
  let(:options) { { 'destination': 'https://destination_key@destination.example.com' } }
  subject { described_class.new(options, arguments, nil) }

  before :each do
    allow(import_backend_step).to receive(:call)
    allow(import_product_step).to receive(:call)
    # disable printer for testing
    allow(json_printer_class).to receive(:new).and_return(ThreeScaleToolbox::CLI::NullPrinter.new)
  end

  context 'valid openapi content' do
    let(:oas_resource) { File.join(resources_path, 'valid_swagger.yaml') }

    before :each do
      expect(import_product_step_class).to receive(:new) do |context|
        context[:report] = {}
        import_product_step
      end
      expect(subject).to receive(:threescale_client)
    end

    it 'does not fail' do
      # Run
      subject.run
    end
  end

  context 'backend import param' do
    let(:oas_resource) { File.join(resources_path, 'valid_swagger.yaml') }
    let(:options) { { backend: true, 'destination': 'https://destination_key@destination.example.com' } }

    before :each do
      expect(import_backend_step_class).to receive(:new) do |context|
        context[:report] = {}
        import_backend_step
      end
      expect(subject).to receive(:threescale_client)
    end

    it 'then backend import called' do
      # Run
      subject.run
    end
  end

  context 'invalid openapi content' do
    let(:oas_content) do
      <<~YAML
        ---
        swagger: "2.0"
        info:
          desSSSSScription: "Invalid description tag"
      YAML
    end
    let(:oas_resource) { tmp_dir.join('invalid.yaml').tap { |conf| conf.write(oas_content) } }

    context '#run' do
      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /OpenAPI schema validation failed/)
      end
    end
  end

  context 'invalid html openapi content' do
    let(:oas_content) do
      <<~EOF
        <!DOCTYPE html>
        <html>
          <body>
            <h1>My First Heading</h1>
            <p>My first paragraph.</p>
          </body>
        </html>
      EOF
    end
    let(:oas_resource) { tmp_dir.join('invalid.yaml').tap { |conf| conf.write(oas_content) } }

    context '#run' do
      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /only JSON\/YAML format is supported/)
      end
    end
  end
end
