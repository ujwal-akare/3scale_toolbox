module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportMetricLimitsStep
          include Step
          ##
          # Writes Plan limits
          def call
            # SET semantics
            # First, delete existing limits
            # Second, add new limits
            plan.limits.each do |limit|
              limit.delete()
              puts "Deleted existing plan limit: [metric: #{limit.metric_id}, #{limit.attrs}]"
            end

            resource_limits_processed.each do |limit_attrs|
              metric_id = limit_attrs.delete('metric_id')
              plan.create_limit(metric_id, limit_attrs)
              puts "Created plan limit: [metric: #{metric_id}, #{limit_attrs}]"
            end
          end

          private

          def resource_limits_processed
            resource_limits.map do |limit|
              metric = find_metric_by_system_name(limit.delete('metric_system_name'))
              # this ImportMetricLimitsStep step is assuming all metrics/methods have been created
              # in previous step, so finding metric should always succeed.
              limit.merge('metric_id' => metric.id)
            end
          end
        end
      end
    end
  end
end
