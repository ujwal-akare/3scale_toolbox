module ThreeScaleToolbox
  module Tasks
    class CopyMappingRulesTask
      include CallableTask
      include CopyTask
      include Helper

      def call
        metrics_map = metrics_mapping(source_service.metrics, copy_service.metrics)
        missing_rules = missing_mapping_rules(source_service.mapping_rules,
                                              copy_service.mapping_rules, metrics_map)
        missing_rules.each do |mapping_rule|
          mapping_rule.delete('links')
          mapping_rule['metric_id'] = metrics_map.fetch(mapping_rule.delete('metric_id'))
          copy_service.create_mapping_rule mapping_rule
        end
        puts "created #{missing_rules.size} mapping rules"
      end

      private

      def missing_mapping_rules(source_mp, copy_mp, metrics_map)
        ThreeScaleToolbox::Helper.array_difference(source_mp, copy_mp) do |mp, copy|
          ThreeScaleToolbox::Helper.compare_hashes(mp, copy, %w[pattern http_method delta]) &&
            metrics_map.fetch(mapping_rule.fetch('metric_id')) == copy.fetch('metric_id')
        end
      end
    end
  end
end
