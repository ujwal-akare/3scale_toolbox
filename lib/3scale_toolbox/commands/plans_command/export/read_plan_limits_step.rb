module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ReadPlanLimitsStep
          include Step
          ##
          # Reads Application Plan limits
          # add metric system_name out of metric_id
          def call
            result[:limits] = plan.limits.map do |limit|
              limit.tap { |l| l['metric'] = metric_info(l, 'Limit') }
            end
          end
        end
      end
    end
  end
end
