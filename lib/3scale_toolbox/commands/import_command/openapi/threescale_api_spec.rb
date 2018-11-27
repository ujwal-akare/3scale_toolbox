module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ThreeScaleApiSpec
          attr_reader :operations

          def self.generate(api)
            new(api.operations)
          end

          def initialize(operations)
            @operations = operations
          end

          def mapping_rules
            operations.map do |operation|
              MappingRule.new(operation)
            end
          end

          def methods
            operations.map do |operation|
              Method.new(operation)
            end
          end
        end
      end
    end
  end
end
