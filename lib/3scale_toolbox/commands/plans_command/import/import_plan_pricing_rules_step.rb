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
            plan.pricing_rules.each do |pr|
              pr.delete()
              puts "Deleted existing plan pricing rule: [metric: #{pr.metric_id}, #{pr.attrs}]"
            end

            resource_pr_processed.each do |pr_attrs|
              metric_id = pr_attrs.delete('metric_id')
              plan.create_pricing_rule(metric_id, pr_attrs)
              puts "Created plan pricing rule: [metric: #{metric_id}, #{pr_attrs}]"
            end
          end

          private

          def resource_pr_processed
            resource_pricing_rules.map do |pr|
              metric = find_metric_by_system_name(pr.delete('metric_system_name'))
              pr.merge('metric_id' => metric.id,
                       'cost_per_unit' => pr.fetch('cost_per_unit').to_f)
            end
          end
        end
      end
    end
  end
end
