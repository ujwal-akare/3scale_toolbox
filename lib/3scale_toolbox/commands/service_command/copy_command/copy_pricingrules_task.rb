module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyPricingRulesTask
          include Task

          def call
            plan_mapping = Helper.application_plan_mapping(source.plans, target.plans)
            plan_mapping.each do |source_plan, target_plan|
              missing_pricing_rules = compute_missing_pricing_rules(source_plan.pricing_rules, target_plan.pricing_rules)
              missing_pricing_rules.each do |pricing_rule|
                target_plan.create_pricing_rule(metrics_map.fetch(pricing_rule.metric_id), pricing_rule.attrs)
              end
              puts "Missing #{missing_pricing_rules.size} pricing rules from target application plan " \
                "#{target_plan.id}. Source plan #{source_plan.id}"
            end
          end

          private

          def metrics_map
            @metrics_map ||= source.metrics_mapping(target)
          end

          def compute_missing_pricing_rules(source_pricing_rules, target_pricing_rules)
            ThreeScaleToolbox::Helper.array_difference(source_pricing_rules, target_pricing_rules) do |src, target_pr|
              src.cost_per_unit == target_pr.cost_per_unit &&
                src.min == target_pr.min &&
                src.max == target_pr.max &&
                metrics_map.fetch(src.metric_id) == target_pr.metric_id
            end
          end
        end
      end
    end
  end
end
