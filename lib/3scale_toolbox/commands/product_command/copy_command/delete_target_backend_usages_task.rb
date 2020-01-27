module ThreeScaleToolbox
  module Commands
    module ProductCommand
      module CopyCommand
        class DeleteTargetBackendUsagesTask
          attr_reader :context

          def initialize(context)
            @context = context
          end

          # entrypoint
          def call
            target.backend_usage_list.each(&:delete)
          end

          private

          def target
            context[:target]
          end
        end
      end
    end
  end
end
