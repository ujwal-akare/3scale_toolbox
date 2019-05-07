require '3scale_toolbox/commands/plans_command/import/step'
require '3scale_toolbox/commands/plans_command/import/create_or_update_app_plan_step'
require '3scale_toolbox/commands/plans_command/import/import_plan_features_step'
require '3scale_toolbox/commands/plans_command/import/import_plan_metrics_step'
require '3scale_toolbox/commands/plans_command/import/import_plan_limits_step'
require '3scale_toolbox/commands/plans_command/import/import_plan_pricing_rules_step'

module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command
          include ThreeScaleToolbox::ResourceReader

          def self.command
            Cri::Command.define do
              name        'import'
              usage       'import [opts] <remote> <service_system_name>'
              summary     'import application plan'
              description 'Import application plan, limits, pricing rules and features'

              option      :f, :file, 'Read from file or url instead of stdin', argument: :required
              option      :p, :plan, 'Override application plan reference', argument: :required
              param       :remote
              param       :service_system_name

              runner ImportSubcommand
            end
          end

          def run
            tasks = []
            tasks << CreateOrUpdateAppPlanStep.new(context)
            tasks << ImportMetricsStep.new(context)
            tasks << ImportMetricLimitsStep.new(context)
            tasks << ImportPricingRulesStep.new(context)
            tasks << ImportPlanFeaturesStep.new(context)

            # run tasks
            tasks.each(&:call)
          end

          private

          def context
            @context ||= create_context
          end

          def create_context
            {
              artifacts_resource: load_resource(options[:file] || '-'),
              threescale_client: threescale_client(arguments[:remote]),
              service_system_name: arguments[:service_system_name],
              plan_system_name: options[:plan],
            }
          end
        end
      end
    end
  end
end
