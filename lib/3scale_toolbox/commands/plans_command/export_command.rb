require '3scale_toolbox/commands/plans_command/export/step'
require '3scale_toolbox/commands/plans_command/export/read_app_plan_step'
require '3scale_toolbox/commands/plans_command/export/read_plan_features_step'
require '3scale_toolbox/commands/plans_command/export/read_plan_limits_step'
require '3scale_toolbox/commands/plans_command/export/read_plan_pricing_rules_step'
require '3scale_toolbox/commands/plans_command/export/read_plan_methods_step'
require '3scale_toolbox/commands/plans_command/export/read_plan_metrics_step'
require '3scale_toolbox/commands/plans_command/export/write_artifacts_file_step'

module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ExportSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'export'
              usage       'export [opts] <remote> <service_system_name> <plan_system_name>'
              summary     'export application plan'
              description 'Export application plan, limits, pricing rules and features'

              option      :f, :file, 'Write to file instead of stdout', argument: :required
              param       :remote
              param       :service_system_name
              param       :plan_system_name

              runner ExportSubcommand
            end
          end

          def run
            tasks = []
            tasks << ReadAppPlanStep.new(context)
            tasks << ReadPlanLimitsStep.new(context)
            tasks << ReadPlanPricingRulesStep.new(context)
            tasks << ReadPlanFeaturesStep.new(context)
            tasks << ReadPlanMethods.new(context)
            tasks << ReadPlanMetrics.new(context)
            tasks << WriteArtifactsStep.new(context)

            # run tasks
            tasks.each(&:call)
          end

          private

          def context
            @context ||= create_context
          end

          def create_context
            {
              file: options[:file],
              threescale_client: threescale_client(arguments[:remote]),
              service_system_name: arguments[:service_system_name],
              plan_system_name: arguments[:plan_system_name],
            }
          end
        end
      end
    end
  end
end
