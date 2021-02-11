module ThreeScaleToolbox
  module CRD
    module BackendMappingRule
      def to_cr
        {
          'httpMethod' => http_method,
          'pattern' => pattern,
          'metricMethodRef' => metric_method_ref,
          'increment' => delta,
          'last' => last,
        }
      end

      def metric_method_ref
        if (method = backend.methods.find { |m| m.id == metric_id })
          method.system_name
        elsif (metric = backend.metrics.find { |m| m.id == metric_id })
          metric.system_name
        else
          raise ThreeScaleToolbox::Error, "Unexpected error. Backend #{backend.system_name} " \
            "mapping rule #{id} referencing to metric id #{metric_id} which has not been found"
        end
      end
    end
  end
end
