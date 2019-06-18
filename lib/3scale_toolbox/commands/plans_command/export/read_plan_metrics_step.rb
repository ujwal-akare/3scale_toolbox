module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ReadPlanMetrics
          include Step
          ##
          # Compute unique list of metrics limits and pricingrules
          def call
            all_metrics = [
              limit_metrics,
              pricingrule_metrics
            ]
            result[:plan_metrics] = all_metrics.each_with_object({}) { |elem, acc| acc.merge!(elem) }
          end

          private

          def limit_metrics
            # multiple limits can reference the same metric
            filtered_limit_metrics.each_with_object({}) do |elem, acc|
              # find_metric should not return nil.
              # It is assumed that metric_id refers to existing element from previous steps
              acc[elem['metric_id']] = find_metric(elem['metric_id'])
            end
          end

          def filtered_limit_metrics
            result[:limits].select { |limit| limit.dig('metric', 'type') == 'metric' }
          end

          def pricingrule_metrics
            filtered_pricing_rule_metrics.each_with_object({}) do |elem, acc|
              # find_metric should not return nil.
              # It is assumed that metric_id refers to existing element from previous steps
              acc[elem['metric_id']] = find_metric(elem['metric_id'])
            end
          end

          def filtered_pricing_rule_metrics
            result[:pricingrules].select { |limit| limit.dig('metric', 'type') == 'metric' }
          end
        end
      end
    end
  end
end
