module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class OpenAPIParser
          attr_reader :operations

          def initialize(openapi)
            @openapi = openapi
            @operations = parse_openapi
          end

          private

          attr_reader :openapi

          def parse_openapi
            openapi.operations.map(&method(:parse_op))
          end

          def parse_op(operation)
            {
              path: "#{openapi.base_path}#{operation.path}",
              verb: operation.verb
            }
          end
        end
      end
    end
  end
end
