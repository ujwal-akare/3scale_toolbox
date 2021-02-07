module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        APP_PLANS_BLACKLIST = %w[id links default custom created_at updated_at].freeze
        LIMITS_BLACKLIST = %w[id metric_id links created_at updated_at].freeze
        PRICINGRULES_BLACKLIST = %w[id metric_id links created_at updated_at].freeze
        PLAN_FEATURE_BLACKLIST = %w[id links created_at updated_at].freeze
        METRIC_BLACKLIST = %w[id links created_at updated_at].freeze

        module Step
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def service
            context[:service] ||= find_service
          end

          def file
            context[:file]
          end

          def threescale_client
            context[:threescale_client]
          end

          # can be id or system_name
          def service_system_name
            context[:service_system_name]
          end

          # can be id or system_name
          def plan_system_name
            context[:plan_system_name]
          end

          def result
            context[:result] ||= {}
          end

          def plan
            context[:plan] ||= find_plan
          end

          def metric_info(elem, elem_name)
            if (method = find_method(elem.fetch('metric_id')))
              { 'type' => 'method', 'system_name' => method.fetch('system_name') }
            elsif (metric = find_metric(elem.fetch('metric_id')))
              { 'type' => 'metric', 'system_name' => metric.fetch('system_name') }
            else
              raise ThreeScaleToolbox::Error, "Unexpected error. #{elem_name} #{elem['id']} " \
                "referencing to metric id #{elem.fetch('metric_id')} which has not been found"
            end
          end

          private

          def find_service
            Entities::Service.find(remote: threescale_client,
                                   ref: service_system_name).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_system_name} does not exist" if svc.nil?
            end
          end

          def find_plan
            Entities::ApplicationPlan.find(service: service, ref: plan_system_name).tap do |p|
              raise ThreeScaleToolbox::Error, "Application plan #{plan_system_name} does not exist" if p.nil?
            end
          end

          def find_metric(id)
            service.metrics.find { |metric| metric['id'] == id }
          end

          def find_method(id)
            service.methods(service.hits.fetch('id')).find { |method| method['id'] == id }
          end
        end
      end
    end
  end
end
