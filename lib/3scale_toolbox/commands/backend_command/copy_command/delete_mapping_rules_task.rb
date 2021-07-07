module ThreeScaleToolbox
  module Commands
    module BackendCommand
      module CopyCommand
        class DeleteMappingRulesTask
          include Task

          # entrypoint
          def run
            return unless delete_mapping_rules

            target_backend.mapping_rules.each(&:delete)
          end
        end
      end
    end
  end
end
