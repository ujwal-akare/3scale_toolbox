module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyMappingRulesTask
          include Task

          def call
            missing_rules = missing_mapping_rules(source.mapping_rules,
                                                  target.mapping_rules, metrics_map)
            missing_rules.each do |mapping_rule|
              mapping_rule.delete('links')
              mapping_rule['metric_id'] = metrics_map.fetch(mapping_rule.delete('metric_id'))
              target.create_mapping_rule mapping_rule
            end
            puts "created #{missing_rules.size} mapping rules"
          end

          private

          def metrics_map
            @metrics_map ||= Helper.metrics_mapping(source_metrics_and_methods, target_metrics_and_methods)
          end

          def missing_mapping_rules(source_rules, target_rules, metrics_map)
            ThreeScaleToolbox::Helper.array_difference(source_rules, target_rules) do |source_rule, target_rule|
              ThreeScaleToolbox::Helper.compare_hashes(source_rule, target_rule, %w[pattern http_method delta]) &&
                metrics_map.fetch(source_rule.fetch('metric_id')) == target_rule.fetch('metric_id')
            end
          end
        end
      end
    end
  end
end
