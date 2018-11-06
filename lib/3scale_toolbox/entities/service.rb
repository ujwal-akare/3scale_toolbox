module ThreeScaleToolbox
  module Entities
    class Service
      VALID_PARAMS = %w[
        name backend_version deployment_option description
        system_name end_user_registration_required
        support_email tech_support_email admin_support_email
      ].freeze
      private_constant :VALID_PARAMS

      class << self
        def create(remote:, service:, system_name:)
          svc_obj = remote.create_service copy_service_params(service, system_name)
          unless svc_obj['errors'].nil?
            raise ThreeScaleToolbox::Error, 'Service has not been saved. ' \
              "Errors: #{svc_obj['errors']}"
          end
          puts "new service id #{svc_obj.fetch('id')}"

          new(id: svc_obj.fetch('id'), remote: remote)
        end

        private

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

      def create_application_plan(plan)
        remote.create_application_plan id, plan
      end

      def plan_limits(plan_id)
        remote.list_application_plan_limits(plan_id)
      end

      def create_application_plan_limit(plan_id, metric_id, limit)
        remote.create_application_plan_limit plan_id, metric_id, limit
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
    end
  end
end
