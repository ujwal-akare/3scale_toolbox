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
              pr.tap { |e| e['metric'] = metric_info(e, 'PricingRule') }
            end
          end
        end
      end
    end
  end
end
