module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class WriteArtifactsStep
          include Step
          ##
          # Serialization of Application Plan objects
          def call
            select_output do |output|
              output.write(serialized_object.to_yaml)
            end
          end

          private

          def select_output
            ios = if file
                    File.open(file, 'w')
                  else
                    $stdout
                  end
            begin
              yield(ios)
            ensure
              ios.close
            end
          end

          def serialized_object
            {
              'plan' => serialized_plan,
              'limits' => serialized_limits,
              'pricingrules' => serialized_pricing_rules,
              'plan_features' => serialized_plan_features,
              'metrics' => serialized_metrics,
              'methods' => serialized_methods,
              'created_at' => Time.now.utc.iso8601,
              'toolbox_version' => ThreeScaleToolbox::VERSION
            }
          end

          def serialized_plan
            result[:plan].reject { |key, _| APP_PLANS_BLACKLIST.include? key }
          end

          def serialized_limits
            result[:limits].map do |limit|
              metric = limit.delete('metric')
              limit['metric_system_name'] = metric['system_name']
              limit.reject { |key, _| LIMITS_BLACKLIST.include? key }
            end
          end

          def serialized_pricing_rules
            result[:pricingrules].map do |pr|
              metric = pr.delete('metric')
              pr['metric_system_name'] = metric['system_name']
              pr.reject { |key, _| PRICINGRULES_BLACKLIST.include? key }
            end
          end

          def serialized_plan_features
            result[:plan_features].map do |pr|
              pr.reject { |key, _| PLAN_FEATURE_BLACKLIST.include? key }
            end
          end

          def serialized_metrics
            result[:plan_metrics].values.map do |metric|
              metric.reject { |key, _| METRIC_BLACKLIST.include? key }
            end
          end

          def serialized_methods
            result[:plan_methods].values.map do |method|
              method.reject { |key, _| METRIC_BLACKLIST.include? key }
            end
          end
        end
      end
    end
  end
end
