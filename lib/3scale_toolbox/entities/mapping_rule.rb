module ThreeScaleToolbox
  module Entities
    class MappingRule
      VALID_PARAMS = %w[metric_id pattern http_method delta position last].freeze
      public_constant :VALID_PARAMS

      class << self
        def create(service:, attrs:)
          mapping_rule = service.remote.create_mapping_rule(
            service.id,
            Helper.filter_params(VALID_PARAMS, attrs)
          )
          if (errors = mapping_rule['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('mapping rule has not been created',
                                                            errors)
          end

          new(id: mapping_rule.fetch('id'), service: service, attrs: mapping_rule)
        end
      end

      attr_reader :id, :service, :remote

      def initialize(id:, service:, attrs: nil)
        @id = id.to_i
        @service = service
        @remote = service.remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= mapping_rule_attrs
      end

      def http_method
        attrs['http_method']
      end

      def pattern
        attrs['pattern']
      end

      def delta
        attrs['delta']
      end

      def last
        attrs['last']
      end

      def metric_id
        attrs['metric_id']
      end

      def update(mr_attrs)
        new_attrs = remote.update_mapping_rule(
          service.id, id,
          Helper.filter_params(VALID_PARAMS, mr_attrs)
        )
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service mapping rule has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_mapping_rule service.id, id
      end

      def to_crd
        {
          'httpMethod' => http_method,
          'pattern' => pattern,
          'metricMethodRef' => metricMethodRef,
          'increment' => delta,
          'last' => last,
        }
      end

      private

      def mapping_rule_attrs
        raise ThreeScaleToolbox::InvalidIdError if id.zero?

        mapping_rule = remote.show_mapping_rule service.id, id
        if (errors = mapping_rule['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service mapping rule not read', errors)
        end

        mapping_rule
      end

      def metricMethodRef
        # TODO each mapping rule will request metric or method metadata, use some cache
        # or metrics and methods index
        begin
          backend_metric = Metric.new(id: metric_id, service: service)
          backend_metric.system_name
        rescue ThreeScale::API::HttpClient::NotFoundError
          backend_method = Method.new(id: metric_id, service: service, parent_id: service.hits.fetch('id'))
          backend_method.system_name
        end
      end
    end
  end
end
