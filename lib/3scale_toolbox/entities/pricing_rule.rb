module ThreeScaleToolbox
  module Entities
    class PricingRule
      include CRD::PricingRuleSerializer

      PRICINGRULES_BLACKLIST = %w[id metric_id links created_at updated_at].freeze

      class << self
        def create(plan:, metric_id:, attrs:)
          resp_attrs = plan.remote.create_pricingrule plan.id, metric_id, attrs
          if (errors = resp_attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Pricing rule has not been created', errors)
          end

          new(id: resp_attrs.fetch('id'), plan: plan, metric_id: metric_id, attrs: resp_attrs)
        end
      end

      attr_reader :id, :plan, :remote, :attrs, :metric_id

      def initialize(id:, plan:, metric_id:, attrs:)
        @id = id.to_i
        @plan = plan
        @remote = plan.remote
        @metric_id = metric_id
        @attrs = attrs
      end

      def cost_per_unit
        attrs['cost_per_unit'].to_f
      end

      def min
        attrs['min']
      end

      def max
        attrs['max']
      end

      def links
        attrs['links'] || []
      end

      def metric_link
        links.find { |link| link['rel'] == 'metric' }
      end

      def delete
        remote.delete_application_plan_pricingrule plan.id, metric_id, id
      end

      def product_metric
        plan.service.metrics.find { |m| m.id == metric_id }
      end

      def product_method
        plan.service.methods.find { |m| m.id == metric_id }
      end

      def backend_metric
        if (backend = backend_from_metric_link)
          return backend.metrics.find { |m| m.id == metric_id }
        end
      end

      def backend_method
        if (backend = backend_from_metric_link)
          return backend.methods.find { |m| m.id == metric_id }
        end
      end

      def to_hash
        extra_attrs = {}

        if (metric = product_metric)
          extra_attrs['metric_system_name'] = metric.system_name
        elsif (method = product_method)
          extra_attrs['metric_system_name'] = method.system_name
        elsif (metric = backend_metric)
          extra_attrs['metric_system_name'] = metric.system_name
          extra_attrs['metric_backend_system_name'] = metric.backend.system_name
        elsif (method = backend_method)
          extra_attrs['metric_system_name'] = method.system_name
          extra_attrs['metric_backend_system_name'] = method.backend.system_name
        else
          raise_method_not_found
        end

        attrs.merge(extra_attrs).reject { |key, _| PRICINGRULES_BLACKLIST.include? key }
      end

      private

      def raise_method_not_found
        raise ThreeScaleToolbox::Error, "Unexpected error. Pricing Rule #{id} " \
          "referencing to metric id #{metric_id} which has not been found"
      end

      # Returns the backend hosting the metric
      def backend_from_metric_link
        if (backend_id = Helper.backend_metric_link_parser(metric_link['href'] || ''))
          return Backend.new(id: backend_id.to_i, remote: remote)
        end
      end
    end
  end
end
