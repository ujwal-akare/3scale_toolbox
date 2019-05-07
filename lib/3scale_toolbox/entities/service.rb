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
        def create(remote:, service:, system_name:)
          svc_obj = create_service(
            remote: remote,
            service: copy_service_params(service, system_name)
          )
          if (errors = svc_obj['errors'])
            raise ThreeScaleToolbox::Error, "Service has not been saved. Errors: #{errors}" \
          end

          new(id: svc_obj.fetch('id'), remote: remote)
        end

        # ref can be system_name or service_id
        def find(remote:, ref:)
          new(id: ref, remote: remote).tap(&:show_service)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(remote: remote, system_name: ref)
        end

        def find_by_system_name(remote:, system_name:)
          service = remote.list_services.find { |svc| svc['system_name'] == system_name }
          return if service.nil?

          new(id: service.fetch('id'), remote: remote)
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

        def copy_service_params(original, system_name)
          service_params = Helper.filter_params(VALID_PARAMS, original)
          service_params.tap do |hash|
            hash['system_name'] = system_name if system_name
          end
        end
      end

      attr_reader :id, :remote

      def initialize(id:, remote:)
        @id = id
        @remote = remote
      end

      def show_service
        remote.show_service id
      end

      def update_proxy(proxy)
        remote.update_proxy id, proxy
      end

      def show_proxy
        remote.show_proxy id
      end

      def metrics
        remote.list_metrics id
      end

      def hits
        hits_metric = metrics.find do |metric|
          metric['system_name'] == 'hits'
        end
        raise ThreeScaleToolbox::Error, 'missing hits metric' if hits_metric.nil?

        hits_metric
      end

      def methods
        remote.list_methods id, hits['id']
      end

      def create_metric(metric)
        remote.create_metric id, metric
      end

      def create_method(parent_metric_id, method)
        remote.create_method id, parent_metric_id, method
      end

      def plans
        remote.list_service_application_plans id
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

      def update_service(params)
        remote.update_service(id, params)
      end

      def delete_service
        remote.delete_service id
      end

      def policies
        remote.show_policies id
      end

      def update_policies(params)
        remote.update_policies(id, params)
      end

      def list_activedocs
        remote.list_activedocs.select do |activedoc|
          # service_id is optional attr. It would return nil and would not match
          # activedocs endpoints return service_id as integers
          activedoc['service_id'] == id.to_i
        end
      end

      def show_oidc
        remote.show_oidc id
      end

      def update_oidc(oidc_settings)
        remote.update_oidc(id, oidc_settings)
      end

      def features
        remote.list_service_features id
      end

      def create_feature(attrs)
        # Workaround until issue is fixed: https://github.com/3scale/porta/issues/774
        attrs['scope'] = 'ApplicationPlan' if attrs['scope'] == 'application_plan'
        attrs['scope'] = 'ServicePlan' if attrs['scope'] == 'service_plan'
        remote.create_service_feature id, attrs
      end
    end
  end
end
