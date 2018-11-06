module ThreeScaleToolbox
  module Tasks
    module Helper
      def metrics_mapping(metrics, copy_metrics)
        copy_metrics.map do |copy|
          metric = metrics.find do |m|
            ThreeScaleToolbox::Helper.compare_hashes(m, copy, ['system_name'])
          end || {}

          [metric['id'], copy['id']]
        end.to_h
      end

      def application_plan_mapping(app_plans, copy_app_plans)
        copy_app_plans.map do |copy|
          plan = app_plans.find do |p|
            ThreeScaleToolbox::Helper.compare_hashes(p, copy, ['system_name'])
          end
          [plan['id'], copy['id']]
        end
      end
    end
  end
end
