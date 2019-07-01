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
              plan_obj = Entities::ApplicationPlan.create(service: service,
                                                          plan_attrs: create_plan_attrs)
              puts "Application plan created: #{plan_obj.id}"
            else
              res = plan_obj.update(update_plan_attrs)
              if (errors = res['errors'])
                raise ThreeScaleToolbox::Error, "Could not update application plan #{plan_system_name}. Errors: #{errors}"
              end

              puts "Application plan updated: #{plan_obj.id}"
            end
          end

          private

          def create_plan_attrs
            resource_plan.merge('system_name' => plan_system_name)
          end

          def update_plan_attrs
            resource_plan.reject { |key, _| %w[system_name].include? key }
          end
        end
      end
    end
  end
end
