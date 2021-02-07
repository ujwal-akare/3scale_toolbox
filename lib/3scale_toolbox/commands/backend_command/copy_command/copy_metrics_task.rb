module ThreeScaleToolbox
  module Commands
    module BackendCommand
      module CopyCommand
        class CopyMetricsTask
          include Task

          # entrypoint
          def run
            missing_metrics.each(&method(:create_metric))
            puts "created #{missing_metrics.size} missing metrics"
          end

          private

          def create_metric(metric)
            Entities::BackendMetric.create(backend: target_backend, attrs: metric.attrs)
          end

          def missing_metrics
            ThreeScaleToolbox::Helper.array_difference(source_backend.metrics, target_backend.metrics) do |source, target|
              source.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
