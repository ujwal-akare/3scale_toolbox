module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateBackendMappingRulesStep
          include Step

          def call
            backend.mapping_rules.each(&:delete)

            report['mapping_rules'] = {}
            operations.each do |op|
              b_m_r = Entities::BackendMappingRule.create(backend: backend, attrs: op.mapping_rule)
              report['mapping_rules'][op.friendly_name] = op.mapping_rule
            end
          end
        end
      end
    end
  end
end
