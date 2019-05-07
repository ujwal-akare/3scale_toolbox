module ThreeScaleToolbox
  module Entities
    class ApplicationPlan
      class << self
        def create(service:, plan_attrs:)
          plan = service.remote.create_application_plan service.id, build_plan_attrs(plan_attrs)
          if (errors = plan['errors'])
            raise ThreeScaleToolbox::Error, "Application plan has not been saved. Errors: #{errors}"
          end

          new(id: plan.fetch('id'), service: service)
        end

        # ref can be system_name or service_id
        def find(service:, ref:)
          new(id: ref, service: service).tap(&:show)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(service: service, system_name: ref)
        end

        def find_by_system_name(service:, system_name:)
          plan = service.plans.find { |p| p['system_name'] == system_name }
          return if plan.nil?

          new(id: plan.fetch('id'), service: service)
        end

        def build_plan_attrs(source_attrs)
          # shallow copy is enough
          source_attrs.clone.tap do |new_plan_attrs|
            # plans are created by default in hidden state
            # If published is required, 'state_event' attr has to be added
            new_plan_attrs['state_event'] = 'publish' if new_plan_attrs['state'] == 'published'
            new_plan_attrs['state_event'] = 'hide' if new_plan_attrs['state'] == 'hidden'
          end
        end
      end

      attr_reader :id, :service, :remote

      def initialize(id:, service:)
        @id = id
        @service = service
        @remote = service.remote
      end

      def show
        remote.show_application_plan service.id, id
      end

      def update(plan_attrs)
        remote.update_application_plan(service.id, id, self.class.build_plan_attrs(plan_attrs))
      end

      def make_default
        plan = remote.application_plan_as_default service.id, id
        if (errors = plan['errors'])
          raise ThreeScaleToolbox::Error, "Application plan has not been set to default. Errors: #{errors}"
        end

        plan
      end

      def disable
        # Split metrics into three groups:
        # a) metrics having limits set with eternity period and zero value, nothing to do.
        # b) metrics having limits set with eternity period, but not zero value, must be updated
        # c) metrics not having limits set with eternity period, must be created

        eternity_limits = limits.select { |limit| limit.fetch('period') == 'eternity' }
        eternity_metric_ids = eternity_limits.map { |limit| limit.fetch('metric_id') }
        service_metric_ids = service.metrics.map { |metric| metric.fetch('id') }
        metric_ids_without_eternity = service_metric_ids - eternity_metric_ids

        # create eternity zero limit for each metric without eternity limit set
        metric_ids_without_eternity.each do |metric_id|
          create_limit(metric_id, zero_eternity_limit_attrs)
        end

        # update eternity zero limit those metrics already having eternity limit set
        not_zero_eternity_limits = eternity_limits.reject { |limit| limit.fetch('value').zero? }
        not_zero_eternity_limits.each do |limit|
          update_limit(limit.fetch('metric_id'), limit.fetch('id'), zero_eternity_limit_attrs)
        end
      end

      def enable
        eternity_zero_limits.each do |limit|
          delete_limit(limit.fetch('metric_id'), limit.fetch('id'))
        end
      end

      def limits
        remote.list_application_plan_limits id
      end

      def create_limit(metric_id, limit_attrs)
        limit = remote.create_application_plan_limit id, metric_id, limit_attrs
        if (errors = limit['errors'])
          raise ThreeScaleToolbox::Error, "Limit has not been created. Errors: #{errors}"
        end

        limit
      end

      def update_limit(metric_id, limit_id, limit_attrs)
        limit = remote.update_application_plan_limit id, metric_id, limit_id, limit_attrs
        if (errors = limit['errors'])
          raise ThreeScaleToolbox::Error, "Limit #{limit_id} has not been updated. Errors: #{errors}"
        end

        limit
      end

      def delete_limit(metric_id, limit_id)
        remote.delete_application_plan_limit id, metric_id, limit_id
      end

      def create_pricing_rule(metric_id, pr_attrs)
        remote.create_pricingrule id, metric_id, pr_attrs
      end

      def pricing_rules
        remote.list_pricingrules_per_application_plan id
      end

      def features
        remote.list_features_per_application_plan id
      end

      def create_feature(feature_id)
        remote.create_application_plan_feature id, feature_id
      end

      def delete
        remote.delete_application_plan service.id, id
      end

      private

      def eternity_zero_limits
        limits.select { |limit| zero_eternity_limit_attrs < limit }
      end

      def zero_eternity_limit_attrs
        { 'period' => 'eternity', 'value' => 0 }
      end
    end
  end
end
