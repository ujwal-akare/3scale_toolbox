require '3scale_toolbox/commands/backend_command/copy_command/task'
require '3scale_toolbox/commands/backend_command/copy_command/create_or_update_target_backend_task'
require '3scale_toolbox/commands/backend_command/copy_command/copy_metrics_task'
require '3scale_toolbox/commands/backend_command/copy_command/copy_methods_task'
require '3scale_toolbox/commands/backend_command/copy_command/delete_mapping_rules_task'
require '3scale_toolbox/commands/backend_command/copy_command/copy_mapping_rules_task'

module ThreeScaleToolbox
  module Commands
    module BackendCommand
      class CopySubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'copy'
            usage       'copy [opts] -s <source-remote> -d <target-remote> <source-backend>'
            summary     'Copy backend'
            description <<-HEREDOC
            This command makes a copy of the referenced backend.
            Target backend will be searched by the source backend system name. System name can be overridden with `--target-system-name` option.
            If a backend with the selected `system-name` is not found, it will be created.
            \n Components of the backend being copied:
            \nmetrics
            \nmethods
            \nmapping rules
            \n\n If a backend with the selected `system-name` is found, it will be updated. Only missing metrics, methods and mapping rules will be created.
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target-system-name', 'Target system name. Default to source system name', argument: :required
            param   :source_backend

            runner CopySubcommand
          end
        end

        def run
          tasks = []
          tasks << CopyCommand::CreateOrUpdateTargetBackendTask.new(context)
          # First metrics as methods need 'hits' metric in target backend
          tasks << CopyCommand::CopyMetricsTask.new(context)
          tasks << CopyCommand::CopyMethodsTask.new(context)
          tasks << CopyCommand::DeleteMappingRulesTask.new(context)
          tasks << CopyCommand::CopyMappingRulesTask.new(context)
          tasks.each(&:call)
        end

        private

        def context
          @context ||= create_context
        end

        def create_context
          {
            source_remote: threescale_client(fetch_required_option(:source)),
            target_remote: threescale_client(fetch_required_option(:destination)),
            source_backend_ref: arguments[:source_backend],
            delete_mapping_rules: true,
            option_target_system_name: options[:'target-system-name']
          }
        end
      end
    end
  end
end
