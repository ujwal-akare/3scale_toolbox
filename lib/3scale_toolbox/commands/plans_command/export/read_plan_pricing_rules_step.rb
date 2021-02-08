module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ReadPlanPricingRulesStep
          include Step
          ##
          # Reads Application Plan pricing rules
          # add metric system_name out of metric_id
          def call
            result[:pricingrules] = plan.pricing_rules.map do |pr|
              pr.attrs.merge('metric' => metric_info(pr, 'PricingRule'), 'cost_per_unit' => pr.cost_per_unit.to_f)
            end
          end
        end
      end
    end
  end
end
