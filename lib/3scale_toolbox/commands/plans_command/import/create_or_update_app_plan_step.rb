module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class CreateOrUpdateAppPlanStep
          include Step
          ##
          # Creates if it does not exist, updates otherwise
          def call
            plan_obj = Entities::ApplicationPlan.find(service: service, ref: plan_system_name)
            if plan_obj.nil?
              plan_obj = Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
              puts "Application plan created: #{plan_obj.id}"
            else
              res = plan_obj.update(plan_attrs)
              if (errors = res['errors'])
                raise ThreeScaleToolbox::Error, "Could not update application plan #{plan_system_name}. Errors: #{errors}"
              end

              puts "Application plan updated: #{plan_obj.id}"
            end
          end

          private

          def plan_attrs
            resource_plan.merge('system_name' => plan_system_name)
          end
        end
      end
    end
  end
end
