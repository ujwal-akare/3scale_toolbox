module ThreeScaleToolbox
  module Tasks
    class CopyMetricsTask
      include CopyTask

      def call
        source_metrics = source.metrics
        target_metrics = target.metrics

        puts "original service has #{source_metrics.size} metrics"
        puts "target service has #{target_metrics.size} metrics"

        missing = missing_metrics(source_metrics, target_metrics)

        missing.each do |metric|
          metric.delete('links')
          Entities::Metric.create(service: target, attrs: metric)
        end

        puts "created #{missing.size} metrics on the target service"
      end

      private

      def missing_metrics(source_metrics, target_metrics)
        ThreeScaleToolbox::Helper.array_difference(source_metrics,
                                                   target_metrics) do |source, target|
          ThreeScaleToolbox::Helper.compare_hashes(source, target, ['system_name'])
        end
      end
    end
  end
end
