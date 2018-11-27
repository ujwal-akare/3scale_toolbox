module ThreeScaleToolbox
  module Tasks
    class DestroyMappingRulesTask
      attr_reader :target

      def initialize(target:, **_other)
        @target = target
      end

      def call
        puts 'destroying all mapping rules of the copy which have been created by default'
        target.mapping_rules.each do |mapping_rule|
          target.delete_mapping_rule mapping_rule['id']
        end
      end
    end
  end
end
