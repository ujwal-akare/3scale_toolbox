module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyApplicationPlansTask
          include Task

          def call
            missing_plans = missing_app_plans(source.plans, target.plans)
            missing_plans.each do |plan|
              plan_attrs = plan.attrs.clone
              plan_attrs.delete('links')
              plan_attrs.delete('default') # TODO: handle default plan
              if plan_attrs.delete('custom') # TODO: what to do with custom plans?
                puts "skipping custom plan #{plan.system_name}"
              else
                ThreeScaleToolbox::Entities::ApplicationPlan.create(service: target, plan_attrs: plan_attrs)
              end
            end
            puts "target service missing #{missing_plans.size} application plans"
          end

          private

          def missing_app_plans(source_plans, target_plans)
            ThreeScaleToolbox::Helper.array_difference(source_plans, target_plans) do |src, target|
              src.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
