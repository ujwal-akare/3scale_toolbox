module ThreeScaleToolbox
  module Tasks
    class DestroyMappingRulesTask
      attr_reader :context

      def initialize(context)
        @context = context
      end

      def call
        puts 'destroying all mapping rules'
        target.mapping_rules.each do |mapping_rule|
          target.delete_mapping_rule mapping_rule['id']
        end
      end

      def target
        context[:target]
      end
    end
  end
end
