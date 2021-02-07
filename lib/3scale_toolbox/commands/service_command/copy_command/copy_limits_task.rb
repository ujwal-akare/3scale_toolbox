module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyLimitsTask
          include Task

          def call
            plan_mapping = Helper.application_plan_mapping(source.plans, target.plans)
            plan_mapping.each do |source_plan, target_plan|
              missing_limits = compute_missing_limits(source_plan.limits, target_plan.limits)
              missing_limits.each do |limit|
                limit.delete('links')
                target_plan.create_limit(metrics_map.fetch(limit.fetch('metric_id')), limit)
              end
              puts "Missing #{missing_limits.size} plan limits from target application plan " \
                "#{target_plan.id}. Source plan #{source_plan.id}"
            end
          end

          private

          def metrics_map
            @metrics_map ||= Helper.metrics_mapping(source_metrics_and_methods, target_metrics_and_methods)
          end

          def compute_missing_limits(source_limits, target_limits)
            ThreeScaleToolbox::Helper.array_difference(source_limits, target_limits) do |limit, target_limit|
              ThreeScaleToolbox::Helper.compare_hashes(limit, target_limit, ['period']) &&
                metrics_map.fetch(limit.fetch('metric_id')) == target_limit.fetch('metric_id')
            end
          end
        end
      end
    end
  end
end
