module ThreeScaleToolbox
  module Commands
    module BackendCommand
      module CopyCommand
        module Task
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def call
            run
          end

          def target_backend=(target)
            context[:target_backend] = target
          end

          def target_backend
            context[:target_backend] ||= raise ThreeScaleToolbox::Error, 'Unexpected error. ' \
              'Target backend should have been created or updated'
          end

          def source_backend
            context[:source_backend] ||= find_source_backend
          end

          def source_methods
            context[:source_methods] ||= source_backend.methods(source_hits)
          end

          def source_hits
            context[:source_hits] ||= source_backend.hits
          end

          def source_metrics
            context[:source_metrics] ||= source_backend.metrics
          end

          def target_metrics
            context[:target_metrics] ||= target_backend.metrics
          end

          def target_hits
            context[:target_hits] ||= target_backend.hits
          end

          def target_methods
            context[:target_methods] ||= target_backend.methods(target_hits)
          end

          def invalidate_target_methods
            context[:target_methods] = nil
          end

          def invalidate_target_metrics
            context[:target_metrics] = nil
          end

          def source_remote
            context[:source_remote]
          end

          def target_remote
            context[:target_remote]
          end

          def source_backend_ref
            context[:source_backend_ref] ||= raise ThreeScaleToolbox::Error, 'Unexpected error. ' \
              'source_backend_ref not found'
          end

          def option_target_system_name
            context[:option_target_system_name]
          end

          private

          def find_source_backend
            Entities::Backend.find(remote: source_remote, ref: source_backend_ref).tap do |backend|
              raise ThreeScaleToolbox::Error, "Backend #{source_backend_ref} does not exist" if backend.nil?
            end
          end
        end
      end
    end
  end
end
