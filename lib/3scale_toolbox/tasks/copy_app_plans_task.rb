module ThreeScaleToolbox
  module Tasks
    class CopyApplicationPlansTask
      include CopyTask

      def call
        source_plans = source.plans
        copy_plans = target.plans
        missing_plans = missing_app_plans(source_plans, copy_plans)
        puts "copied service missing #{missing_plans.size} application plans"

        missing_plans.each do |plan|
          plan.delete('links')
          plan.delete('default') # TODO: handle default plan
          if plan.delete('custom') # TODO: what to do with custom plans?
            puts "skipping custom plan #{plan}"
          else
            target.create_application_plan(plan)
          end
        end
      end

      private

      def missing_app_plans(source_plans, copy_plans)
        ThreeScaleToolbox::Helper.array_difference(source_plans, copy_plans) do |plan, copy|
          ThreeScaleToolbox::Helper.compare_hashes(plan, copy, ['system_name'])
        end
      end
    end
  end
end
