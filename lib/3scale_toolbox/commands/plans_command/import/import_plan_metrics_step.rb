module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportMetricsStep
          include Step
          ##
          # Writes Plan metrics and methods
          def call
            missing_metrics.each(&method(:create_metric))
            missing_methods.each(&method(:create_method))

            # invalidate memoized methods and metrics
            invalidate_service_methods
            invalidate_service_metrics
          end

          private

          def missing_metrics
            # service metrics list includes methods
            # this array_difference method computes elements in resource_metrics not included in service_metrics
            # So methods will not be in the "missing_metrics" list, as long as array diff semantics are kept.
            ThreeScaleToolbox::Helper.array_difference(resource_metrics, service_metrics) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, ['system_name'])
            end
          end

          def missing_methods
            ThreeScaleToolbox::Helper.array_difference(resource_methods, service_methods) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, ['system_name'])
            end
          end

          def create_metric(metric_attrs)
            metric = service.create_metric(metric_attrs)
            if (errors = metric['errors'])
              raise ThreeScaleToolbox::Error, "Metric has not been created. #{errors}"
            end

            puts "Created metric: #{metric['system_name']}"
          end

          def create_method(method_attrs)
            method = service.create_method(service_hits['id'], method_attrs)
            if (errors = method['errors'])
              raise ThreeScaleToolbox::Error, "Method has not been created. #{errors}" \

            end

            puts "Created method: #{method_attrs['system_name']}"
          end
        end
      end
    end
  end
end
