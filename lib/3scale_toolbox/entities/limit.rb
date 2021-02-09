module ThreeScaleToolbox
  module Entities
    class Limit
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

      def to_crd
        {
          'period' => period,
          'value' => value,
          'metricMethodRef' => metric_method_ref,
        }
      end

      private

      def metric_method_ref
        # Find in service methods
        # Find in service metrics
        # Parse backend_id from pricing rule links
        # Find in backend methods
        # Find in backend metrics
        if (method = plan.service.methods.find { |m| m.id == metric_id })
          { 'systemName' => method.system_name }
        elsif (metric = plan.service.metrics.find { |m| m.id == metric_id })
          { 'systemName' => metric.system_name }
        elsif (backend_id = Helper.backend_metric_link_parser(metric_link['href'] || ''))
          backend = Backend.new(id: backend_id, remote: remote)
          if (backend_metric = backend.metrics.find { |m| m.id == metric_id })
            { 'systemName' => backend_metric.system_name, 'backend' => backend.system_name }
          elsif (backend_method = backend.methods.find { |m| m.id == metric_id })
            { 'systemName' => backend_method.system_name, 'backend' => backend.system_name }
          else
            raise ThreeScaleToolbox::Error, "Unexpected error. PricingRule #{id} " \
              "referencing to metric id #{metric_id} which has not been found"
          end
        else
          raise ThreeScaleToolbox::Error, "Unexpected error. PricingRule #{id} " \
            "referencing to metric id #{metric_id} which has not been found"
        end
      end
    end
  end
end
