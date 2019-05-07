module ThreeScaleToolbox
  module Tasks
    class CopyApplicationPlansTask
      include CopyTask

      def call
        source_plans = source.plans
        target_plans = target.plans
        missing_plans = missing_app_plans(source_plans, target_plans)
        missing_plans.each do |plan|
          plan.delete('links')
          plan.delete('default') # TODO: handle default plan
          if plan.delete('custom') # TODO: what to do with custom plans?
            puts "skipping custom plan #{plan}"
          else
            ThreeScaleToolbox::Entities::ApplicationPlan.create(service: target, plan_attrs: plan)
          end
        end
        puts "target service missing #{missing_plans.size} application plans"
      end

      private

      def missing_app_plans(source_plans, target_plans)
        ThreeScaleToolbox::Helper.array_difference(source_plans, target_plans) do |src, target|
          ThreeScaleToolbox::Helper.compare_hashes(src, target, ['system_name'])
        end
      end
    end
  end
end
