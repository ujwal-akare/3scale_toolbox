module ThreeScaleToolbox
  module Tasks
    class CopyMetricsTask
      include CopyTask

      def call
        source_metrics = source_service.metrics
        copy_metrics = copy_service.metrics

        puts "original service has #{source_metrics.size} metrics"
        puts "copied service has #{copy_metrics.size} metrics"

        m_m = missing_metrics(source_metrics, copy_metrics)

        m_m.each do |metric|
          metric.delete('links')
          copy_service.create_metric(metric)
        end

        puts "created #{m_m.size} metrics on the copied service"
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
