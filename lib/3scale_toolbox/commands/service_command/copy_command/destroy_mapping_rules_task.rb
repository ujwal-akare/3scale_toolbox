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

            puts 'destroying all mapping rules'
            target.mapping_rules.each do |mapping_rule|
              target.delete_mapping_rule mapping_rule['id']
            end
          end

          private

          def delete_mapping_rules
            context.fetch(:delete_mapping_rules, false)
          end

          def target
            context[:target]
          end
        end
      end
    end
  end
end
