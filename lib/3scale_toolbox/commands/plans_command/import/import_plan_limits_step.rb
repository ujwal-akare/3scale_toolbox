module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportMetricLimitsStep
          include Step
          ##
          # Writes Plan limits
          def call
            missing_limits.each do |limit|
              metric_id = limit.delete('metric_id')
              limit_obj = plan.create_limit(metric_id, limit)
              if (errors = limit_obj['errors'])
                raise ThreeScaleToolbox::Error, "Plan limit has not been created. #{errors}"
              end

              puts "Created plan limit: [metric: #{metric_id}, #{limit}]"
            end
          end

          private

          def missing_limits
            ThreeScaleToolbox::Helper.array_difference(resource_limits_processed, plan.limits) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, %w[metric_id period])
            end
          end

          def resource_limits_processed
            resource_limits.map do |limit|
              metric = find_metric_by_system_name(limit.delete('metric_system_name'))
              # this ImportMetricLimitsStep step is assuming all metrics/methods have been created
              # in previous step, so finding metric should always succeed.
              limit.merge('metric_id' => metric.fetch('id'))
            end
          end
        end
      end
    end
  end
end
