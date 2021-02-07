module ThreeScaleToolbox
  module Commands
    module BackendCommand
      module CopyCommand
        class CopyMappingRulesTask
          include Task

          # entrypoint
          def run
            missing_rules = missing_mapping_rules(source_backend.mapping_rules,
                                                  target_backend.mapping_rules, metrics_map)
            missing_rules.each do |mapping_rule|
              mapping_rule.metric_id = metrics_map.fetch(mapping_rule.metric_id)
              Entities::BackendMappingRule.create(backend: target_backend,
                                                  attrs: mapping_rule.attrs)
            end
            puts "created #{missing_rules.size} mapping rules"
          end

          private

          def metrics_map
            @metrics_map ||= build_metrics_mapping
          end

          def build_metrics_mapping
            target_mm = target_backend.metrics + target_backend.methods(target_backend.hits)
            source_mm = source_backend.metrics + source_backend.methods(source_backend.hits)
            target_mm.map do |target|
              source = source_mm.find do |m|
                m.system_name == target.system_name
              end
              next if source.nil?

              [source.id, target.id]
            end.compact.to_h
          end

          def missing_mapping_rules(source_rules, target_rules, metrics_map)
            ThreeScaleToolbox::Helper.array_difference(source_rules, target_rules) do |source, target|
              # map metric_id to the target backend domain
              source_attrs = source.attrs.merge('metric_id' => metrics_map.fetch(source.metric_id))
              ThreeScaleToolbox::Helper.compare_hashes(source_attrs,
                                                       target.attrs,
                                                       %w[pattern http_method delta metric_id])
            end
          end
        end
      end
    end
  end
end
