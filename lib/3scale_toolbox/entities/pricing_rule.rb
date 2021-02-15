module ThreeScaleToolbox
  module Entities
    class PricingRule
      include CRD::PricingRuleSerializer

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

      private

      # Used by CRD::PricingRule
      # Returns the backend hosting the metric
      def backend_from_metric
        backend_id = Helper.backend_metric_link_parser(metric_link['href'] || '')
        return if backend_id.nil?

        Backend.new(id: backend_id.to_i, remote: remote)
      end
    end
  end
end
