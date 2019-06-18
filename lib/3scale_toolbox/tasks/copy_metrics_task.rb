module ThreeScaleToolbox
  module Tasks
    class CopyMetricsTask
      include CopyTask

      def call
        puts "original service has #{source_metrics.size} metrics"
        puts "target service has #{target_metrics.size} metrics"
        missing_metrics.each(&method(:create_metric))
        puts "created #{missing_metrics.size} metrics on the target service"
        invalidate_target_metrics if missing_metrics.size.positive?
      end

      private

      def create_metric(metric)
        new_metric = metric.reject { |key, _| %w[id links].include? key }
        Entities::Metric.create(service: target, attrs: new_metric)
      rescue ThreeScaleToolbox::ThreeScaleApiError => e
        raise e unless ThreeScaleToolbox::Helper.system_name_already_taken_error?(e.apierrors)

        warn "[WARN] metric #{metric.fetch('system_name')} not created. " \
          'Method with the same system_name exists.'
      end

      def missing_metrics
        @missing_metrics ||= ThreeScaleToolbox::Helper.array_difference(source_metrics, target_metrics) do |source, target|
          ThreeScaleToolbox::Helper.compare_hashes(source, target, ['system_name'])
        end
      end
    end
  end
end
