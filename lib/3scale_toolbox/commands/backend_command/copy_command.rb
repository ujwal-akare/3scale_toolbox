require '3scale_toolbox/commands/backend_command/copy_command/task'
require '3scale_toolbox/commands/backend_command/copy_command/create_or_update_target_backend_task'
require '3scale_toolbox/commands/backend_command/copy_command/copy_metrics_task'
require '3scale_toolbox/commands/backend_command/copy_command/copy_methods_task'
require '3scale_toolbox/commands/backend_command/copy_command/copy_mapping_rules_task'

module ThreeScaleToolbox
  module Commands
    module BackendCommand
      class CopySubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'copy'
            usage       'copy [opts] <source_remote> <target_remote> <source_backend>'
            summary     'Copy backend'
            description <<-HEREDOC
            This command makes a copy of the referenced backend.
            Target backend will be searched by source backend system name. System name can be overriden with `--target_system_name` option.
            If a backend with the selected `system_name` is not found, it will be created.
            \n Components of the backend being copied:
            \nmetrics
            \nmethods
            \nmapping rules
            HEREDOC

            option  :t, 'target_system_name', 'Target system name. Default to source system name', argument: :required
            param   :source_remote
            param   :target_remote
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
          tasks << CopyCommand::CopyMappingRulesTask.new(context)
          tasks.each(&:call)
        end

        private

        def context
          @context ||= create_context
        end

        def create_context
          {
            source_remote: threescale_client(arguments[:source_remote]),
            target_remote: threescale_client(arguments[:target_remote]),
            source_backend_ref: arguments[:source_backend],
            option_target_system_name: options[:target_system_name]
          }
        end
      end
    end
  end
end
