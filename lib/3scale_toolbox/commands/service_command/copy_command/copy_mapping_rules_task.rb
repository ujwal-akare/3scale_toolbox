module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyMappingRulesTask
          include Task

          def call
            missing_rules.each do |mapping_rule|
              mr_attrs = mapping_rule.attrs.merge('metric_id' => metrics_map.fetch(mapping_rule.metric_id))
              Entities::MappingRule.create(service: target, attrs: mr_attrs)
            end
            logger.info "created #{missing_rules.size} mapping rules"
            report['missing_mapping_rules_created'] = missing_rules.size
          end

          private

          def metrics_map
            @metrics_map ||= source.metrics_mapping(target)
          end

          def missing_rules
            @missing_rules ||= ThreeScaleToolbox::Helper.array_difference(source.mapping_rules, target.mapping_rules) do |source_rule, target_rule|
              source_rule.pattern == target_rule.pattern &&
                source_rule.http_method == target_rule.http_method &&
                source_rule.delta == target_rule.delta &&
                metrics_map.fetch(source_rule.metric_id) == target_rule.metric_id
            end
          end
        end
      end
    end
  end
end
