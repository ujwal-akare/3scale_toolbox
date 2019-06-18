module ThreeScaleToolbox
  module Tasks
    class CopyPricingRulesTask
      include CopyTask
      include Helper

      def call
        plan_mapping = application_plan_mapping(source.plans, target.plans)
        plan_mapping.each do |plan_id, target_plan|
          pricing_rules_source = source.remote.list_pricingrules_per_application_plan(plan_id)
          pricing_rules_target = target.remote.list_pricingrules_per_application_plan(target_plan['id'])
          missing_pricing_rules = missing_pricing_rules(pricing_rules_source, pricing_rules_target,
                                                        metrics_map)
          missing_pricing_rules.each do |pricing_rule|
            pricing_rule.delete('links')
            target.remote.create_pricingrule(
              target_plan['id'],
              metrics_map.fetch(pricing_rule['metric_id']),
              pricing_rule
            )
          end
          puts "Missing #{missing_pricing_rules.size} pricing rules from target application plan " \
            "#{target_plan['id']}. Source plan #{plan_id}"
        end
      end

      private

      def metrics_map
        @metrics_map ||= metrics_mapping(source_metrics_and_methods, target_metrics_and_methods)
      end

      def missing_pricing_rules(source_pricing_rules, target_pricing_rules, metrics_map)
        ThreeScaleToolbox::Helper.array_difference(source_pricing_rules, target_pricing_rules) do |src, target|
          ThreeScaleToolbox::Helper.compare_hashes(src, target, %w[cost_per_unit min max]) &&
            metrics_map.fetch(src.fetch('metric_id')) == target.fetch('metric_id')
        end
      end
    end
  end
end
