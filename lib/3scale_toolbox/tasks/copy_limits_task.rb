module ThreeScaleToolbox
  module Tasks
    class CopyLimitsTask
      include CopyTask
      include Helper

      def call
        metrics_map = metrics_mapping(source_service.metrics, copy_service.metrics)
        plan_mapping = application_plan_mapping(source_service.plans, copy_service.plans)
        plan_mapping.each do |plan_id, copy_id|
          limits = source_service.plan_limits(plan_id)
          limits_copy = copy_service.plan_limits(copy_id)
          m_l = missing_limits(limits, limits_copy)
          m_l.each do |limit|
            limit.delete('links')
            copy_service.create_application_plan_limit(
              copy_id,
              metrics_map.fetch(limit.fetch('metric_id')),
              limit
            )
          end
          puts "copied application plan #{copy_id} is missing #{m_l.size} " \
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
