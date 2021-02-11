module ThreeScaleToolbox
  module CRD
    class BackendParser
      Metric = Struct.new(:system_name, :friendly_name, :description, :unit)
      Method = Struct.new(:system_name, :friendly_name, :description)
      MappingRule = Struct.new(:metric_ref, :http_method, :pattern, :delta, :last)

      attr_reader :cr

      def initialize(cr)
        @cr = cr
      end

      def system_name
        cr.dig('spec', 'systemName')
      end

      def name
        cr.dig('spec', 'name')
      end

      def description
        cr.dig('spec', 'description')
      end

      def private_endpoint
        cr.dig('spec', 'privateBaseURL')
      end

      def metrics
        @metrics ||= (cr.dig('spec', 'metrics') || {}).map do |system_name, metric|
          Metric.new(system_name, metric['friendlyName'], metric['description'], metric['unit'])
        end
      end

      def methods
        @methods ||= (cr.dig('spec', 'methods') || {}).map do |system_name, method|
          Method.new(system_name, method['friendlyName'], method['description'])
        end
      end

      def mapping_rules
        @mapping_rules ||= (cr.dig('spec', 'mappingRules') || []).map do |mapping_rule|
          MappingRule.new(mapping_rule['metricMethodRef'], mapping_rule['httpMethod'],
            mapping_rule['pattern'], mapping_rule['increment'], mapping_rule['last'])
        end
      end

      # Metrics and methods index by system_name
      def metrics_index
        @metrics_index ||= (methods + metrics).each_with_object({}) { |metric, h| h[metric.system_name] = metric }
      end
    end
  end
end
