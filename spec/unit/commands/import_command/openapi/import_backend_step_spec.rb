RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ImportBackendStep do
  subject { described_class.new(openapi_context) }
  let(:openapi_context) { { override_private_base_url: 'https://example.com' } }

  context '#call' do
    it 'all required tasks are run' do
      # Task stubs
      [
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateBackendStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateBackendMethodsStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateBackendMappingRulesStep,
      ].each do |task_class|
        task = instance_double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end

      subject.call
    end

    context 'private endpoint not provided' do
      let(:api_spec) { double() }
      let(:openapi_context) { { api_spec: api_spec, override_private_base_url: nil } }

      before :each do
        allow(api_spec).to receive(:host).and_return(nil)
      end

      it 'raises error' do
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error,
                                               /private endpoint not specified/)
      end
    end
  end
end
