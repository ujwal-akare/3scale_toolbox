module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateMappingRulesStep
          include Step

          def call
            # operations from context (should) have metric_id
            context[:operations].each do |op|
              service.create_mapping_rule(op.mapping_rule)
              puts "Created #{op.http_method} #{op.pattern} endpoint"
            end
          end
        end
      end
    end
  end
end
