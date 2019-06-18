module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ReadPlanMethods
          include Step
          ##
          # Compute unique list of methods from limits and pricingrules
          def call
            methods = [
              limit_methods,
              pricingrule_methods
            ]
            result[:plan_methods] = methods.each_with_object({}) { |elem, acc| acc.merge!(elem) }
          end

          private

          def limit_methods
            # multiple limits can reference the same method
            filtered_limit_methods.each_with_object({}) do |elem, acc|
              # find_method should not return nil.
              # It is assumed that metric_id refers to existing element from previous steps
              acc[elem['metric_id']] = find_method(elem['metric_id'])
            end
          end

          def filtered_limit_methods
            result[:limits].select { |limit| limit.dig('metric', 'type') == 'method' }
          end

          def pricingrule_methods
            filtered_pricing_rule_methods.each_with_object({}) do |elem, acc|
              # find_method should not return nil.
              # It is assumed that metric_id refers to existing element from previous steps
              acc[elem['metric_id']] = find_method(elem['metric_id'])
            end
          end

          def filtered_pricing_rule_methods
            result[:pricingrules].select { |limit| limit.dig('metric', 'type') == 'method' }
          end
        end
      end
    end
  end
end
