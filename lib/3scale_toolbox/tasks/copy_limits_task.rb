module ThreeScaleToolbox
  module Tasks
    class CopyLimitsTask
      include CopyTask
      include Helper

      def call
        metrics_map = metrics_mapping(source.metrics, target.metrics)
        plan_mapping = application_plan_mapping(source.plans, target.plans)
        plan_mapping.each do |plan_id, target_plan|
          source_plan = ThreeScaleToolbox::Entities::ApplicationPlan.new(id: plan_id, service: source)
          target_plan = ThreeScaleToolbox::Entities::ApplicationPlan.new(id: target_plan['id'], service: target)
          missing_limits = missing_limits(source_plan.limits, target_plan.limits, metrics_map)
          missing_limits.each do |limit|
            limit.delete('links')
            target_plan.create_limit(metrics_map.fetch(limit.fetch('metric_id')), limit)
          end
          puts "Missing #{missing_limits.size} plan limits from target application plan " \
            "#{target_plan.id}. Source plan #{plan_id}"
        end
      end

      private

      def missing_limits(source_limits, target_limits, metrics_map)
        ThreeScaleToolbox::Helper.array_difference(source_limits, target_limits) do |limit, target|
          ThreeScaleToolbox::Helper.compare_hashes(limit, target, ['period']) &&
            metrics_map.fetch(limit.fetch('metric_id')) == target.fetch('metric_id')
        end
      end
    end
  end
end
