require '3scale_toolbox/commands/metrics_command/create_command'
require '3scale_toolbox/commands/metrics_command/list_command'
require '3scale_toolbox/commands/metrics_command/apply_command'
require '3scale_toolbox/commands/metrics_command/delete_command'

module ThreeScaleToolbox
  module Commands
    module MetricsCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'metric'
          usage       'metric <sub-command> [options]'
          summary     'metric super command'
          description 'Metric commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(Create::CreateSubcommand)
      add_subcommand(List::ListSubcommand)
      add_subcommand(Apply::ApplySubcommand)
      add_subcommand(Delete::DeleteSubcommand)
    end
  end
end
