module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateMethodsStep
          include Step

          def call
            hits_metric_id = service.hits['id']
            # store operations in context
            # each operation can be extended with extra information to be used later
            context[:operations] = api_spec.operations
            operations.each do |op|
              res = service.create_method(hits_metric_id, op.method)
              op.set(:metric_id, res['id'])
            end
          end
        end
      end
    end
  end
end
