module ThreeScaleToolbox
  module Tasks
    class CopyPricingRulesTask
      include CopyTask
      include Helper

      def call
        metrics_map = metrics_mapping(source.metrics, target.metrics)
        plan_mapping = application_plan_mapping(source.plans, target.plans)
        plan_mapping.each do |plan_id, target_plan|
          pricing_rules_source = source.remote.list_pricingrules_per_application_plan(plan_id)
          pricing_rules_target = target.remote.list_pricingrules_per_application_plan(target_plan['id'])
          missing_pricing_rules = missing_pricing_rules(pricing_rules_source, pricing_rules_target)
          missing_pricing_rules.each do |pricing_rule|
            links = pricing_rule.delete('links')
            target.remote.create_pricingrule(
              target_plan['id'],
              metrics_map.fetch(parse_metric_id_from_links(links)),
              pricing_rule
            )
          end
          puts "Missing #{missing_pricing_rules.size} pricing rules from target application plan " \
            "#{target_plan['id']}. Source plan #{plan_id}"
        end
      end

      private

      def missing_pricing_rules(source_pricing_rules, target_pricing_rules)
        ThreeScaleToolbox::Helper.array_difference(source_pricing_rules, target_pricing_rules) do |src, target|
          ThreeScaleToolbox::Helper.compare_hashes(src, target, ['system_name'])
        end
      end

      def parse_metric_id_from_links(pricing_rule_links)
        # This method will not be necessary when https://github.com/3scale/porta/issues/671 is fixed.
        # When method
        # https://3scale-supertest-admin.3scale.net/admin/api/services/2555417769646/metrics/2555418155744/methods/2555418155754
        # When metric
        # https://3scale-supertest-admin.3scale.net/admin/api/services/2555417769646/metrics/2555418160039
        metric_link = pricing_rule_links.select { |link| link['rel'] == 'metric' }[0]
        metric_href = metric_link['href']
        m = metric_href.match(%r{/methods/(?<metric_id>\d+)$}) || metric_href.match(%r{/metrics/(?<metric_id>\d+)$})
        m[:metric_id].to_i
      end
    end
  end
end
