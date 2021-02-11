module ThreeScaleToolbox
  module Entities
    class BackendMappingRule
      include CRD::BackendMappingRuleSerializer

      VALID_PARAMS = %w[metric_id pattern http_method delta position last].freeze
      public_constant :VALID_PARAMS

      class << self
        def create(backend:, attrs:)
          mapping_rule = backend.remote.create_backend_mapping_rule(
            backend.id,
            Helper.filter_params(VALID_PARAMS, attrs)
          )
          if (errors = mapping_rule['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend mapping rule has not been created',
                                                            errors)
          end

          new(id: mapping_rule.fetch('id'), backend: backend, attrs: mapping_rule)
        end
      end

      attr_reader :id, :backend, :remote

      def initialize(id:, backend:, attrs: nil)
        @id = id.to_i
        @backend = backend
        @remote = backend.remote
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

      def pattern
        attrs['pattern']
      end

      def http_method
        attrs['http_method']
      end

      def delta
        attrs['delta']
      end

      def update(mr_attrs)
        new_attrs = remote.update_backend_mapping_rule(
          backend.id, id,
          Helper.filter_params(VALID_PARAMS, mr_attrs)
        )
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend mapping rule has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_backend_mapping_rule backend.id, id
      end

      private

      def mapping_rule_attrs
        raise ThreeScaleToolbox::InvalidIdError if id.zero?

        mapping_rule = remote.backend_mapping_rule backend.id, id
        if (errors = mapping_rule['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend mapping rule not read', errors)
        end

        mapping_rule
      end
    end
  end
end
