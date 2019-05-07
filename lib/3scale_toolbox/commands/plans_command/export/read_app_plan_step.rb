module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ReadAppPlanStep
          include Step
          ##
          # Reads Application plan
          def call
            result[:plan] = plan.show
          end
        end
      end
    end
  end
end
