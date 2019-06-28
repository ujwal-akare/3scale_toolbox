module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportPricingRulesStep
          include Step
          ##
          # Writes Plan pricing rules
          def call
            missing_pricing_rules.each do |pr|
              metric_id = pr.delete('metric_id')
              resp = plan.create_pricing_rule(metric_id, pr)
              if (errors = resp['errors'])
                raise ThreeScaleToolbox::Error, "Plan pricing rule has not been created. #{errors}"
              end

              puts "Created plan pricing rule: [metric: #{metric_id}, #{pr}]"
            end
          end

          private

          def missing_pricing_rules
            ThreeScaleToolbox::Helper.array_difference(resource_pr_processed, remote_pr_processed) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, %w[metric_id cost_per_unit min max])
            end
          end

          def remote_pr_processed
            plan.pricing_rules.map do |pr|
              pr.merge('cost_per_unit' => pr.fetch('cost_per_unit').to_f)
            end
          end

          def resource_pr_processed
            resource_pricing_rules.map do |pr|
              metric = find_metric_by_system_name(pr.delete('metric_system_name'))
              pr.merge('metric_id' => metric.fetch('id'),
                       'cost_per_unit' => pr.fetch('cost_per_unit').to_f)
            end
          end
        end
      end
    end
  end
end
