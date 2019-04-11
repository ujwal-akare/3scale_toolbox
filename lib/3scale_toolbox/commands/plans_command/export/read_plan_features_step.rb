module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ReadPlanFeaturesStep
          include Step
          ##
          # Reads Application Plan features
          def call
            result[:plan_features] = plan.features
          end
        end
      end
    end
  end
end
