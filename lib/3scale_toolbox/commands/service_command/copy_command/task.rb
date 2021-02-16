module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        module Task
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def source
            context[:source] ||= find_source_service
          end

          def find_source_service
            Entities::Service.find(remote: source_remote, ref: source_service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{source_service_ref} does not exist" if svc.nil?
            end
          end

          def target
            context[:target] ||= raise ThreeScaleToolbox::Error, 'Unexpected error. ' \
              'Target service should have been created or updated'
          end

          def target=(target)
            context[:target] = target
          end

          def delete_mapping_rules
            context.fetch(:delete_mapping_rules, false)
          end

          def force_delete_mapping_rules
            context[:delete_mapping_rules] = true
          end

          def source_metrics_and_methods
            source.metrics + source.methods
          end

          def target_metrics_and_methods
            target.metrics + target.methods
          end

          def source_remote
            context[:source_remote]
          end

          def target_remote
            context[:target_remote]
          end

          def source_service_ref
            context[:source_service_ref] ||= raise ThreeScaleToolbox::Error, 'Unexpected error. ' \
              'source_service_ref not found'
          end

          def option_target_system_name
            context[:option_target_system_name]
          end
        end
      end
    end
  end
end
