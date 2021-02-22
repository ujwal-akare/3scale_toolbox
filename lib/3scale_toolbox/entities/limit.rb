module ThreeScaleToolbox
  module Entities
    class Limit
      include CRD::Limit

      class << self
        def create(plan:, metric_id:, attrs:)
          resp_attrs = plan.remote.create_application_plan_limit plan.id, metric_id, attrs
          if (errors = resp_attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Limit has not been created', errors)
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

      def period
        attrs['period']
      end

      def value
        attrs['value']
      end

      def links
        attrs['links'] || []
      end

      def metric_link
        links.find { |link| link['rel'] == 'metric' }
      end

      def update(new_limit_attrs)
        new_attrs = remote.update_application_plan_limit(plan.id, metric_id, id, new_limit_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Limit has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_application_plan_limit plan.id, metric_id, id
      end

      private

      # Used by CRD::Limit
      # Returns the backend hosting the metric
      def backend_from_metric
        backend_id = Helper.backend_metric_link_parser(metric_link['href'] || '')
        return if backend_id.nil?

        Backend.new(id: backend_id.to_i, remote: remote)
      end
    end
  end
end
