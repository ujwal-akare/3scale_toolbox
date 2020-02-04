require '3scale_toolbox/commands/service_command/copy_command/task'
require '3scale_toolbox/commands/service_command/copy_command/create_or_update_service_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_limits_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_mapping_rules_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_activedocs_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_app_plans_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_methods_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_metrics_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_policies_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_pricingrules_task'
require '3scale_toolbox/commands/service_command/copy_command/copy_service_proxy_task'
require '3scale_toolbox/commands/service_command/copy_command/destroy_mapping_rules_task'
require '3scale_toolbox/commands/service_command/copy_command/bump_proxy_version_task'

module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      class CopySubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'copy'
            usage       'copy [opts] -s <src> -d <dst> <source-service>'
            summary     'Copy service'
            description <<-HEREDOC
            This command makes a copy of the referenced service.
            Target service will be searched by source service system name. System name can be overriden with `--target_system_name` option.
            If a service with the selected `system_name` is not found, it will be created.
            \n Components of the service being copied:
            \nservice settings
            \nproxy settings
            \npricing rules
            \nactivedocs
            \nmetrics
            \nmethods
            \napplication plans
            \nmapping rules
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name. Default to source system name', argument: :required
            flag    :f, :force, 'Overwrites the mapping rules by deleting all rules from target service first'
            flag    :r, 'rules-only', 'Only mapping rules are copied'
            param   :source_service

            runner CopySubcommand
          end
        end

        def run
          tasks = []
          unless option_rules_only
            tasks << CopyCommand::CreateOrUpdateTargetServiceTask.new(context)
            tasks << CopyCommand::CopyServiceProxyTask.new(context)
            tasks << CopyCommand::CopyMethodsTask.new(context)
            tasks << CopyCommand::CopyMetricsTask.new(context)
            tasks << CopyCommand::CopyApplicationPlansTask.new(context)
            tasks << CopyCommand::CopyLimitsTask.new(context)
            tasks << CopyCommand::CopyPoliciesTask.new(context)
            tasks << CopyCommand::CopyPricingRulesTask.new(context)
            tasks << CopyCommand::CopyActiveDocsTask.new(context)
          end
          tasks << CopyCommand::DestroyMappingRulesTask.new(context)
          tasks << CopyCommand::CopyMappingRulesTask.new(context)
          tasks.each(&:call)

          # This should be the last step
          CopyCommand::BumpProxyVersionTask.new(service: context[:target]).call
        end

        private

        def context
          @context ||= create_context
        end

        def create_context
          {
            source_remote: threescale_client(fetch_required_option(:source)),
            target_remote: threescale_client(fetch_required_option(:destination)),
            source_service_ref: arguments[:source_service],
            option_target_system_name: options[:target_system_name],
            delete_mapping_rules: options[:force]
          }
        end

        def option_rules_only
          options[:'rules-only']
        end
      end
    end
  end
end
