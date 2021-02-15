module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyApplicationPlansTask
          include Task

          def call
            missing_regular_plans.each do |plan|
              plan_attrs = plan.attrs.clone
              plan_attrs.delete('links')
              plan_attrs.delete('default') # TODO: handle default plan
              ThreeScaleToolbox::Entities::ApplicationPlan.create(service: target, plan_attrs: plan_attrs)
            end

            logger.info "target service missing #{missing_regular_plans.size} application plans"
            report['missing_application_plans_created'] = missing_regular_plans.size
          end

          private

          def missing_regular_plans
            missing_plans.reject(&:custom)
          end

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
