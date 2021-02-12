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
                target_plan.create_limit(metrics_map.fetch(limit.metric_id), limit.attrs)
              end
              puts "Missing #{missing_limits.size} plan limits from target application plan " \
                "#{target_plan.id}. Source plan #{source_plan.id}"
            end
          end

          private

          def metrics_map
            @metrics_map ||= source.metrics_mapping(target)
          end

          def compute_missing_limits(source_limits, target_limits)
            ThreeScaleToolbox::Helper.array_difference(source_limits, target_limits) do |limit, target_limit|
              limit.period == target_limit.period && metrics_map.fetch(limit.metric_id) == target_limit.metric_id
            end
          end
        end
      end
    end
  end
end
