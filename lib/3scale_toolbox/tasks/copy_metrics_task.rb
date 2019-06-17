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
          metric.delete('id')
          metric.delete('links')
          create_metric(metric)
        end

        puts "created #{missing.size} metrics on the target service"
      end

      private

      def create_metric(metric)
        Entities::Metric.create(service: target, attrs: metric)
      rescue ThreeScaleToolbox::ThreeScaleApiError => e
        raise e unless system_name_already_taken?(e.apierrors)

        warn "[WARN] metric #{metric.fetch('system_name')} not created. " \
          'Method with the same system_name exists.'
      end

      def system_name_already_taken?(error)
        Array(Hash(error)['system_name']).any? { |msg| msg.match(/already been taken/) }
      end

      def missing_metrics(source_metrics, target_metrics)
        ThreeScaleToolbox::Helper.array_difference(source_metrics,
                                                   target_metrics) do |source, target|
          ThreeScaleToolbox::Helper.compare_hashes(source, target, ['system_name'])
        end
      end
    end
  end
end
