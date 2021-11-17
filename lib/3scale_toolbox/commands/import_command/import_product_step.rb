module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ImportProductStep
          include Step

          def call
            tasks = []
            tasks << CreateServiceStep.new(context)
            # other tasks might read proxy settings (CreateActiveDocsStep does)
            tasks << UpdateServiceProxyStep.new(context)
            tasks << CreateMethodsStep.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask.new(context)
            tasks << CreateMappingRulesStep.new(context)
            tasks << CreateActiveDocsStep.new(context)
            tasks << UpdateServiceOidcConfStep.new(context)
            tasks << UpdatePoliciesStep.new(context)

            # run tasks
            tasks.each(&:call)

            # This should be the last step
            ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::BumpProxyVersionTask.new(service: context[:target]).call
          end
        end
      end
    end
  end
end
