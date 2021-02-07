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
                pricing_rule.delete('links')
                target_plan.create_pricing_rule(metrics_map.fetch(pricing_rule['metric_id']), pricing_rule)
              end
              puts "Missing #{missing_pricing_rules.size} pricing rules from target application plan " \
                "#{target_plan.id}. Source plan #{source_plan.id}"
            end
          end

          private

          def metrics_map
            @metrics_map ||= Helper.metrics_mapping(source_metrics_and_methods, target_metrics_and_methods)
          end

          def compute_missing_pricing_rules(source_pricing_rules, target_pricing_rules)
            ThreeScaleToolbox::Helper.array_difference(source_pricing_rules, target_pricing_rules) do |src, target_pr|
              ThreeScaleToolbox::Helper.compare_hashes(src, target_pr, %w[cost_per_unit min max]) &&
                metrics_map.fetch(src.fetch('metric_id')) == target_pr.fetch('metric_id')
            end
          end
        end
      end
    end
  end
end
