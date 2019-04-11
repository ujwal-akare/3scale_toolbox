module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
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
            context[:plan_system_name] || artifacts_resource.dig('plan', 'system_name')
          end

          def result
            context[:result] ||= {}
          end

          def plan
            context[:plan] ||= find_plan
          end

          def resource_plan
            artifacts_resource.fetch('plan') do
              raise ThreeScaleToolbox::Error, 'Invalid content. Plan not found'
            end
          end

          def resource_metrics
            artifacts_resource['metrics'] || []
          end

          def resource_methods
            artifacts_resource['methods'] || []
          end

          def resource_limits
            artifacts_resource['limits'] || []
          end

          def resource_pricing_rules
            artifacts_resource['pricingrules'] || []
          end

          def resource_features
            artifacts_resource['plan_features'] || []
          end

          def service_metrics
            context[:service_metrics] ||= service.metrics
          end

          def invalidate_service_metrics
            context[:service_metrics] = nil
          end

          def service_hits
            context[:service_hits] ||= find_service_hits
          end

          def service_methods
            context[:service_methods] ||= service.methods
          end

          def invalidate_service_methods
            context[:service_methods] = nil
          end

          def service_features
            context[:service_features] ||= service.features
          end

          # deserialized artifacts content
          def artifacts_resource
            context[:artifacts_resource]
          end

          def find_feature_by_system_name(system_name)
            service_features.find { |feature| feature['system_name'] == system_name }
          end

          def find_metric_by_system_name(system_name)
            service_metrics.find { |metric| metric['system_name'] == system_name }
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

          def find_service_hits
            find_metric_by_system_name('hits').tap do |hits_metric|
              raise ThreeScaleToolbox::Error, 'missing hits metric' if hits_metric.nil?
            end
          end
        end
      end
    end
  end
end
