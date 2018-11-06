module ThreeScaleToolbox
  module Tasks
    class DestroyMappingRulesTask
      include CallableTask

      attr_reader :copy_service

      def initialize(copy_service:, **_other)
        @copy_service = copy_service
      end

      def call
        puts 'destroying all mapping rules of the copy which have been created by default'
        copy_service.mapping_rules.each do |mapping_rule|
          copy_service.delete_mapping_rule mapping_rule['id']
        end
      end
    end
  end
end
