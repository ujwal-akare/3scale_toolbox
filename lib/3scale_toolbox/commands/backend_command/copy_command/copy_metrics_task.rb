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
            @missing_metrics ||= ThreeScaleToolbox::Helper.array_difference(source_backend.metrics, target_backend.metrics) do |s_m, t_m|
              s_m.system_name == t_m.system_name
            end
          end
        end
      end
    end
  end
end
