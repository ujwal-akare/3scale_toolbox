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
            invalidate_target_metrics if missing_metrics.size.positive?
          end

          private

          def create_metric(metric)
            Entities::BackendMetric.create(backend: target_backend, attrs: metric.attrs)
          end

          def missing_metrics
            @missing_metrics ||= ThreeScaleToolbox::Helper.array_difference(source_metrics, target_metrics) do |source, target|
              source.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
