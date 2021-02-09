module ThreeScaleToolbox
  module Entities
    class BackendRemote
      attr_reader :methods, :mapping_rules, :metrics, :attrs

      def initialize(methods:, attrs:, mapping_rules:, metrics:)
        @methods = methods
        @attrs = attrs
        @mapping_rules = mapping_rules
        @metrics = metrics
      end

      def list_backend_methods(*args)
        methods
      end

      def list_backend_mapping_rules(*args)
        mapping_rules
      end

      def http_client
        HttpClient = Struct.new(:endpoint)
        HttpClient.new('http://fromCR')
      end

      def list_backend_metrics(*args)
        metrics
      end

      def backend(*args)
        attrs
      end
    end
  end
end
