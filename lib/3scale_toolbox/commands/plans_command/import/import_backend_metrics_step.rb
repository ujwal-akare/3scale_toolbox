module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportBackendMetricsStep
          include Step
          ##
          # Writes Plan metrics and methods
          def call
            resource_backend_metrics.each(&method(:create_metric))
            resource_backend_methods.each(&method(:create_method))
          end

          private

          def create_metric(metric_attrs)
            backend = find_backend(metric_attrs.fetch('backend_system_name'))

            unless backend.metrics.any? { |m| m.system_name == metric_attrs.fetch('system_name') }
              Entities::BackendMetric.create(backend: backend, attrs: metric_attrs)
              puts "Created backend metric: #{metric_attrs.fetch('system_name')}; backend: #{backend.system_name}"
            end
          end

          def create_method(method_attrs)
            backend = find_backend(method_attrs.fetch('backend_system_name'))

            unless backend.methods.any? { |m| m.system_name == method_attrs.fetch('system_name') }
              Entities::BackendMethod.create(backend: backend, attrs: method_attrs)
              puts "Created backend method: #{method_attrs.fetch('system_name')}; backend: #{backend.system_name}"
            end
          end
        end
      end
    end
  end
end
