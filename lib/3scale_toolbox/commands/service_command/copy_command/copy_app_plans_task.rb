module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyApplicationPlansTask
          include Task

          def call
            missing_plans.each do |plan|
              plan_attrs = plan.attrs.clone
              plan_attrs.delete('links')
              plan_attrs.delete('default') # TODO: handle default plan
              if plan_attrs.delete('custom') # TODO: what to do with custom plans?
                logger.info "skipping custom plan #{plan.system_name}"
              else
                ThreeScaleToolbox::Entities::ApplicationPlan.create(service: target, plan_attrs: plan_attrs)
              end
            end
            logger.info "target service missing #{missing_plans.size} application plans"
            report['missing_application_plans_created'] = missing_plans.size
          end

          private

          def missing_plans
            @missing_plans ||= ThreeScaleToolbox::Helper.array_difference(source.plans, target.plans) do |src, target|
              src.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
