require '3scale_toolbox'

RSpec.shared_examples 'openapi import' do
  include_context :resources

  let(:api_spec) { double('api_spec') }
  let(:remote) { double('remote') }

  before :each do
    expect(subject).to receive(:openapi_resource).and_return(oas_resource)
    threescale_api_spec_stub = class_double(ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ThreeScaleApiSpec).as_stubbed_const
    expect(threescale_api_spec_stub).to receive(:parse).and_return(api_spec)
    expect_any_instance_of(ThreeScaleToolbox::Remotes).to receive(:remote).and_return(remote)
  end

  it 'all required tasks are run' do
    # Task stubs
    required_tasks.each do |task_class|
      task = double(task_class.to_s)
      task_class_obj = class_double(task_class).as_stubbed_const
      expect(task_class_obj).to receive(:new).and_return(task)
      expect(task).to receive(:call)
    end

    # Run
    subject.run
  end
end

RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::OpenAPISubcommand do
  let(:arguments) { { 'openapi_resource': 'some_resource' } }
  subject { described_class.new(options, arguments, nil) }
  let(:oas_resource) { [oas_content, { format: :yaml }] }

  context 'create service' do
    let(:options) { { 'destination': 'https://destination_key@destination.example.com' } }
    let(:oas_content) { File.read(File.join(resources_path, 'valid_swagger.yaml')) }

    context '#run' do
      let(:required_tasks) do
        [
          ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateServiceStep,
          ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMethodsStep,
          ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMappingRulesStep
        ]
      end

      it_behaves_like 'openapi import'
    end
  end

  context 'update service' do
    context '#run' do
      let(:options) do
        {
          'destination': 'https://destination_key@destination.example.com',
          'service': 'some_service_id'
        }
      end
      let(:oas_content) { File.read(File.join(resources_path, 'valid_swagger.yaml')) }
      let(:required_tasks) do
        [
          ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMethodsStep,
          ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMappingRulesStep
        ]
      end
      it_behaves_like 'openapi import'
    end
  end

  context 'invalid openapi content' do
    let(:options) { { 'destination': 'https://destination_key@destination.example.com' } }
    let(:oas_content) do
      <<~YAML
        ---
        swagger: "2.0"
        info:
          desSSSSScription: "Invalid description tag"
      YAML
    end

    context '#run' do
      it 'raises error' do
        expect(subject).to receive(:openapi_resource).and_return(oas_resource)
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /OpenAPI schema validation failed/)
      end
    end
  end
end
