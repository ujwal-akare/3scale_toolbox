RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ImportProductStep do
  subject { described_class.new(openapi_context) }
  let(:openapi_context) { {} }

  context '#call' do
    it 'all required tasks are run' do
      # Task stubs
      [
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateServiceStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdateServiceProxyStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMethodsStep,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMappingRulesStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateActiveDocsStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdateServiceOidcConfStep,
        ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::UpdatePoliciesStep,
        ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::BumpProxyVersionTask,
      ].each do |task_class|
        task = instance_double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end

      subject.call
    end
  end
end
