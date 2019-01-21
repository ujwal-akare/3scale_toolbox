module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ThreeScaleApiSpec
          attr_reader :openapi

          def initialize(openapi)
            @openapi = openapi
          end

          def title
            openapi.info.title
          end

          def description
            openapi.info.description
          end

          def operations
            openapi.operations.map do |op|
              Operation.new(
                path: "#{openapi.base_path}#{op.path}",
                verb: op.verb,
                operationId: op.operationId
              )
            end
          end
        end
      end
    end
  end
end
