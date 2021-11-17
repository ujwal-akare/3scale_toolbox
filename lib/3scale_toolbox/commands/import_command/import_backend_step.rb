module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ImportBackendStep
          include Step

          def call
            verify_params

            tasks = []
            tasks << CreateBackendStep.new(context)
            tasks << CreateBackendMethodsStep.new(context)
            tasks << CreateBackendMappingRulesStep.new(context)

            # run tasks
            tasks.each(&:call)
          end

          private

          def verify_params
            # TODO only backend params
          end
        end
      end
    end
  end
end
