module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateMappingRulesStep
          include Step

          def call
            api_spec.mapping_rules.each do |mapping_rule|
              service.create_mapping_rule(mapping_rule.to_h)
              puts "Created #{mapping_rule.http_method} #{mapping_rule.pattern} endpoint"
            end
          end
        end
      end
    end
  end
end
