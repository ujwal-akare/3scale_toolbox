module ThreeScaleToolbox
  module Tasks
    class CopyLimitsTask
      include CopyTask
      include Helper

      def call
        metrics_map = metrics_mapping(source.metrics, target.metrics)
        plan_mapping = application_plan_mapping(source.plans, target.plans)
        plan_mapping.each do |plan_id, copy_id|
          limits = source.plan_limits(plan_id)
          limits_copy = target.plan_limits(copy_id)
          missing_limits = missing_limits(limits, limits_copy)
          missing_limits.each do |limit|
            limit.delete('links')
            target.create_application_plan_limit(
              copy_id,
              metrics_map.fetch(limit.fetch('metric_id')),
              limit
            )
          end
          puts "copied application plan #{copy_id} is missing #{missing_limits.size} " \
               "from the original plan #{plan_id}"
        end
      end

      private

      def missing_limits(source_limits, copy_limits)
        ThreeScaleToolbox::Helper.array_difference(source_limits, copy_limits) do |limit, copy|
          ThreeScaleToolbox::Helper.compare_hashes(limit, copy, ['period'])
        end
      end
    end
  end
end
