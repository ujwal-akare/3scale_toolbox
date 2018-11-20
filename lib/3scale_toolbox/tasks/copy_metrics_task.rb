module ThreeScaleToolbox
  module Tasks
    class CopyMetricsTask
      include CopyTask

      def call
        source_metrics = source.metrics
        copy_metrics = target.metrics

        puts "original service has #{source_metrics.size} metrics"
        puts "copied service has #{copy_metrics.size} metrics"

        missing_metrics = missing_metrics(source_metrics, copy_metrics)

        missing_metrics.each do |metric|
          metric.delete('links')
          target.create_metric(metric)
        end

        puts "created #{missing_metrics.size} metrics on the copied service"
      end

      private

      def missing_metrics(source_metrics, copy_metrics)
        ThreeScaleToolbox::Helper.array_difference(source_metrics, copy_metrics) do |metric, copy|
          ThreeScaleToolbox::Helper.compare_hashes(metric, copy, ['system_name'])
        end
      end
    end
  end
end
