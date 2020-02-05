module ThreeScaleToolbox
  module Commands
    module ProductCommand
      module CopyCommand
        class DeleteExistingTargetBackendUsagesTask
          attr_reader :context

          def initialize(context)
            @context = context
          end

          # entrypoint
          def call
            conflicting_target_backend_usage_list.each(&:delete)
          end

          private

          # List of target backend usage items that match source backend usage paths
          def conflicting_target_backend_usage_list
            # Compute array intersection
            target_backend_usage_list.select do |target_usage|
              source_backend_usage_list.find do |source_usage|
                target_usage.path == source_usage.path
              end
            end
          end

          def source_backend_usage_list
            @source_backend_usage_list ||= source.backend_usage_list
          end

          def target_backend_usage_list
            @target_backend_usage_list ||= target.backend_usage_list
          end

          def target
            context[:target]
          end

          def source
            context[:source]
          end
        end
      end
    end
  end
end
