module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class Operation
          include Method
          include MappingRule

          attr_reader :operation

          def initialize(operation)
            @operation = operation
          end

          def set(key, val)
            operation[key] = val
          end
        end
      end
    end
  end
end
