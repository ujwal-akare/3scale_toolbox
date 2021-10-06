module ThreeScaleToolbox
  module CRD
    module Limit
      def to_cr
        {
          'period' => period,
          'value' => value,
          'metricMethodRef' => metric_system_name,
        }
      end

      def metric_system_name
        # Find in service methods
        # Find in service metrics
        # Find in backend methods
        # Find in backend metrics
        if (method = plan.service.methods.find { |m| m.id == metric_id })
          { 'systemName' => method.system_name }
        elsif (metric = plan.service.metrics.find { |m| m.id == metric_id })
          { 'systemName' => metric.system_name }
        elsif (backend = backend_from_metric_link)
          if (backend_metric = backend.metrics.find { |m| m.id == metric_id })
            { 'systemName' => backend_metric.system_name, 'backend' => backend.system_name }
          elsif (backend_method = backend.methods.find { |m| m.id == metric_id })
            { 'systemName' => backend_method.system_name, 'backend' => backend.system_name }
          else
            raise ThreeScaleToolbox::Error, "Unexpected error. Limit #{id} " \
              "referencing to metric id #{metric_id} which has not been found"
          end
        else
          raise ThreeScaleToolbox::Error, "Unexpected error. Limit #{id} " \
            "referencing to metric id #{metric_id} which has not been found"
        end
      end
    end
  end
end
