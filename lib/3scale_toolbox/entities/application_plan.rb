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
        remote.update_application_plan service.id, id, build_plan_attrs(plan_attrs)
      end

      def limits
        remote.list_application_plan_limits id
      end

      def create_limit(metric_id, limit_attrs)
        remote.create_application_plan_limit id, metric_id, limit_attrs
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
    end
  end
end
