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
          end

          private

          def missing_metrics
            ThreeScaleToolbox::Helper.array_difference(resource_metrics, service.metrics) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, ['system_name'])
            end
          end

          def missing_methods
            ThreeScaleToolbox::Helper.array_difference(resource_methods, service.methods) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, ['system_name'])
            end
          end

          def create_metric(metric_attrs)
            metric = ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: metric_attrs)
            puts "Created metric: #{metric.attrs['system_name']}"
          end

          def create_method(method_attrs)
            method = ThreeScaleToolbox::Entities::Method.create(service: service, attrs: method_attrs)
            puts "Created method: #{method.attrs['system_name']}"
          end
        end
      end
    end
  end
end
