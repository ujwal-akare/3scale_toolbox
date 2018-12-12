module ThreeScaleToolbox
  module Tasks
    module Helper
      def metrics_mapping(source_metrics, target_metrics)
        target_metrics.map do |target|
          source = source_metrics.find do |m|
            ThreeScaleToolbox::Helper.compare_hashes(m, target, ['system_name'])
          end || {}

          [source['id'], target['id']]
        end.to_h
      end

      def application_plan_mapping(source_app_plans, target_app_plans)
        mapping = target_app_plans.map do |target|
          source = source_app_plans.find do |app_plan|
            ThreeScaleToolbox::Helper.compare_hashes(app_plan, target, ['system_name'])
          end || {}
          [source['id'], target]
        end
        mapping.reject { |key, _| key.nil? }
      end
    end
  end
end
