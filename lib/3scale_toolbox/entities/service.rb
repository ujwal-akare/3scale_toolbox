module ThreeScaleToolbox
  module Entities
    class Service
      VALID_PARAMS = %w[
        name backend_version deployment_option description
        system_name end_user_registration_required
        support_email tech_support_email admin_support_email
      ].freeze
      public_constant :VALID_PARAMS

      class << self
        def create(remote:, service_params:)
          svc_attrs = create_service(
            remote: remote,
            service: filtered_service_params(service_params)
          )
          if (errors = svc_attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Service has not been created', errors)
          end

          new(id: svc_attrs.fetch('id'), remote: remote, attrs: svc_attrs)
        end

        # ref can be system_name or service_id
        def find(remote:, ref:)
          new(id: ref, remote: remote).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(remote: remote, system_name: ref)
        end

        def find_by_system_name(remote:, system_name:)
          service_list = remote.list_services

          if service_list.respond_to?(:has_key?) && (errors = service_list['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Service list not read', errors)
          end

          service_attrs = service_list.find { |svc| svc['system_name'] == system_name }
          return if service_attrs.nil?

          new(id: service_attrs.fetch('id'), remote: remote, attrs: service_attrs)
        end

        private

        def create_service(remote:, service:)
          svc_obj = remote.create_service service

          # Source and target remotes might not allow same set of deployment options
          # Invalid deployment option check
          # use default deployment_option
          if (errors = svc_obj['errors']) &&
             ThreeScaleToolbox::Helper.service_invalid_deployment_option?(errors)
            service.delete('deployment_option')
            svc_obj = remote.create_service(service)
          end

          svc_obj
        end

        def filtered_service_params(original_params)
          Helper.filter_params(VALID_PARAMS, original_params)
        end
      end

      attr_reader :id, :remote

      def initialize(id:, remote:, attrs: nil)
        @id = id
        @remote = remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= service_attrs
      end

      def update_proxy(proxy)
        new_proxy_attrs = remote.update_proxy id, proxy

        if (errors = new_proxy_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service proxy not updated', errors)
        end

        new_proxy_attrs
      end

      def proxy
        proxy_attrs = remote.show_proxy id
        if (errors = proxy_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service proxy not read', errors)
        end

        proxy_attrs
      end

      def metrics
        service_metrics = remote.list_metrics id
        if service_metrics.respond_to?(:has_key?) && (errors = service_metrics['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service metrics not read', errors)
        end

        service_metrics
      end

      def hits
        hits_metric = metrics.find do |metric|
          metric['system_name'] == 'hits'
        end
        raise ThreeScaleToolbox::Error, 'missing hits metric' if hits_metric.nil?

        hits_metric
      end

      def methods(parent_metric_id)
        service_methods = remote.list_methods id, parent_metric_id
        if service_methods.respond_to?(:has_key?) && (errors = service_methods['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service methods not read', errors)
        end

        service_methods
      end

      def plans
        service_plans = remote.list_service_application_plans id
        if service_plans.respond_to?(:has_key?) && (errors = service_plans['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service plans not read', errors)
        end

        service_plans
      end

      def mapping_rules
        remote.list_mapping_rules id
      end

      def delete_mapping_rule(rule_id)
        remote.delete_mapping_rule(id, rule_id)
      end

      def create_mapping_rule(mapping_rule)
        remote.create_mapping_rule id, mapping_rule
      end

      def update(svc_attrs)
        new_attrs = safe_update(svc_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service not updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_service id
      end

      def policies
        remote.show_policies id
      end

      def update_policies(params)
        remote.update_policies(id, params)
      end

      def activedocs
        tenant_activedocs = remote.list_activedocs

        if tenant_activedocs.respond_to?(:has_key?) && (errors = tenant_activedocs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service activedocs not read', errors)
        end

        tenant_activedocs.select do |activedoc|
          # service_id is optional attr. It would return nil and would not match
          # activedocs endpoints return service_id as integers
          activedoc['service_id'] == id.to_i
        end
      end

      def oidc
        service_oidc = remote.show_oidc id

        if (errors = service_oidc['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service oicdc not read', errors)
        end

        service_oidc
      end

      def update_oidc(oidc_settings)
        new_oidc = remote.update_oidc(id, oidc_settings)

        if (errors = new_oidc['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service oicdc not updated', errors)
        end

        new_oidc
      end

      def features
        service_features = remote.list_service_features id

        if service_features.respond_to?(:has_key?) && (errors = service_features['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service features not read', errors)
        end

        service_features
      end

      def create_feature(feature_attrs)
        # Workaround until issue is fixed: https://github.com/3scale/porta/issues/774
        feature_attrs['scope'] = 'ApplicationPlan' if feature_attrs['scope'] == 'application_plan'
        feature_attrs['scope'] = 'ServicePlan' if feature_attrs['scope'] == 'service_plan'
        new_feature = remote.create_service_feature id, feature_attrs

        if (errors = new_feature['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service feature not created', errors)
        end

        new_feature
      end

      def proxy_configs(environment)
        proxy_configs_attrs = remote.proxy_config_list(id, environment)
        if proxy_configs_attrs.respond_to?(:has_key?) && (errors = proxy_configs_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfigs not read', errors)
        end

        proxy_configs_attrs.map do |proxy_config_attrs|
          Entities::ProxyConfig.new(environment: environment, service: self, version: proxy_config_attrs.fetch("version"), attrs: proxy_config_attrs)
        end
      end

      private

      def service_attrs
        svc = remote.show_service id
        if (errors = svc['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Service attrs not read', errors)
        end

        svc
      end

      def safe_update(svc_attrs)
        new_attrs = remote.update_service id, svc_attrs

        # Source and target remotes might not allow same set of deployment options
        # Invalid deployment option check
        # use default deployment_option
        if (errors = new_attrs['errors']) &&
           ThreeScaleToolbox::Helper.service_invalid_deployment_option?(errors)
          svc_attrs.delete('deployment_option')
          new_attrs = remote.update_service id, svc_attrs
        end

        new_attrs
      end
    end
  end
end
