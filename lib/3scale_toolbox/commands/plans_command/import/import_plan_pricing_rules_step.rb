module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportPricingRulesStep
          include Step
          ##
          # Writes Plan pricing rules
          def call
            # SET semantics
            # First, delete existing pricing rules
            # Second, add new pricing rules
            remote_pr_processed.each do |pr|
              metric_id = pr.fetch('metric_id')
              plan.delete_pricing_rule metric_id, pr.fetch('id')
              puts "Deleted existing plan pricing rule: [metric: #{metric_id}, #{pr}]"
            end

            resource_pr_processed.each do |pr|
              metric_id = pr.delete('metric_id')
              plan.create_pricing_rule(metric_id, pr)
              puts "Created plan pricing rule: [metric: #{metric_id}, #{pr}]"
            end
          end

          private

          def remote_pr_processed
            plan.pricing_rules.map do |pr|
              pr.merge('cost_per_unit' => pr.fetch('cost_per_unit').to_f)
            end
          end

          def resource_pr_processed
            resource_pricing_rules.map do |pr|
              metric = find_metric_by_system_name(pr.delete('metric_system_name'))
              pr.merge('metric_id' => metric.fetch('id'),
                       'cost_per_unit' => pr.fetch('cost_per_unit').to_f)
            end
          end
        end
      end
    end
  end
end
