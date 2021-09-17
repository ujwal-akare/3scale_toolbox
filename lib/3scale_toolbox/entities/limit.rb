module ThreeScaleToolbox
  module Entities
    class Limit
      include CRD::Limit

      LIMITS_BLACKLIST = %w[id metric_id links created_at updated_at].freeze

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
          raise_metric_not_found
        end

        attrs.merge(extra_attrs).reject { |key, _| LIMITS_BLACKLIST.include? key }
      end

      private

      def raise_metric_not_found
        raise ThreeScaleToolbox::Error, "Unexpected error. Limit #{id} " \
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
