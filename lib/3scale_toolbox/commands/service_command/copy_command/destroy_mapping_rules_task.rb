module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class DestroyMappingRulesTask
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def call
            return unless delete_mapping_rules

            logger.info 'destroying all mapping rules'
            target.mapping_rules.each(&:delete)
          end

          private

          def delete_mapping_rules
            context.fetch(:delete_mapping_rules, false)
          end

          def target
            context.fetch(:target)
          end

          def logger
            context.fetch(:logger)
          end
        end
      end
    end
  end
end
