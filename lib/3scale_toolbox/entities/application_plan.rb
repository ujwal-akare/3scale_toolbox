module ThreeScaleToolbox
  module Entities
    class ApplicationPlan
      class << self
        def create(service:, plan_attrs:)
          plan = service.remote.create_application_plan service.id, create_plan_attrs(plan_attrs)
          if (errors = plan['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Application plan has not been created', errors)
          end

          new(id: plan.fetch('id'), service: service, attrs: plan)
        end

        # ref can be system_name or service_id
        def find(service:, ref:)
          new(id: ref, service: service).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(service: service, system_name: ref)
        end

        def find_by_system_name(service:, system_name:)
          plan = service.plans.find { |p| p['system_name'] == system_name }
          return if plan.nil?

          new(id: plan.fetch('id'), service: service, attrs: plan)
        end

        def create_plan_attrs(source_attrs)
          # shallow copy is enough
          source_attrs.clone.tap do |new_plan_attrs|
            # plans are created by default in hidden state
            # If published is required, 'state_event' attr has to be added
            state = new_plan_attrs.delete('state')
            new_plan_attrs['state_event'] = 'publish' if state == 'published'
          end
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
        @attrs ||= read_plan_attrs
      end

      def update(plan_attrs)
        return attrs if update_plan_attrs(plan_attrs).empty?

        new_attrs = remote.update_application_plan(service.id, id,
                                                   update_plan_attrs(plan_attrs))
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Application plan has not been updated', errors)
        end

        @attrs = new_attrs

        new_attrs
      end

      def make_default
        plan = remote.application_plan_as_default service.id, id
        if (errors = plan['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Application plan has not been set to default', errors)
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
        plan_limits = remote.list_application_plan_limits id
        if plan_limits.respond_to?(:has_key?) && (errors = plan_limits['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Limits per application plan not read', errors)
        end

        plan_limits
      end

      def metric_limits(metric_id)
        # remote.list_metric_limits(plan_id, metric_id) returns all limits for a given metric,
        # without filtering by app plan
        # Already reported. https://issues.jboss.org/browse/THREESCALE-2486
        # Meanwhile, the strategy will be to get all metrics from a given plan
        # and filter by metric_id
        limits.select { |limit| limit['metric_id'] == metric_id }
      end

      def create_limit(metric_id, limit_attrs)
        limit = remote.create_application_plan_limit id, metric_id, limit_attrs
        if (errors = limit['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Limit has not been created', errors)
        end

        limit
      end

      def update_limit(metric_id, limit_id, limit_attrs)
        limit = remote.update_application_plan_limit id, metric_id, limit_id, limit_attrs
        if (errors = limit['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Limit not updated', errors)
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

      def applications
        app_attrs_list = remote.list_applications(service_id: service.id, plan_id: id)
        if app_attrs_list.respond_to?(:has_key?) && (errors = app_attrs_list['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Plan applications not read', errors)
        end

        app_attrs_list.map do |app_attrs|
          Entities::Application.new(id: app_attrs.fetch('id'), remote: remote, attrs: app_attrs)
        end
      end

      def published?
        attrs.fetch('state') == 'published'
      end

      private

      def read_plan_attrs
        plan_attrs = remote.show_application_plan service.id, id
        if (errors = plan_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Application plan not read', errors)
        end

        plan_attrs
      end

      def update_plan_attrs(update_attrs)
        new_attrs = update_attrs.reject { |key, _| %w[id links system_name].include? key }
        new_attrs.tap do |params|
          state = params.delete('state')
          params['state_event'] = 'publish' if state == 'published' && !published?
          params['state_event'] = 'hide' if state == 'hidden' && published?
        end
      end

      def eternity_zero_limits
        limits.select { |limit| zero_eternity_limit_attrs < limit }
      end

      def zero_eternity_limit_attrs
        { 'period' => 'eternity', 'value' => 0 }
      end
    end
  end
end
