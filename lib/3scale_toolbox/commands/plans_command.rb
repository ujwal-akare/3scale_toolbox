require '3scale_toolbox/commands/plans_command/export_command'
require '3scale_toolbox/commands/plans_command/import_command'
require '3scale_toolbox/commands/plans_command/create_command'
require '3scale_toolbox/commands/plans_command/apply_command'
require '3scale_toolbox/commands/plans_command/list_command'
require '3scale_toolbox/commands/plans_command/show_command'
require '3scale_toolbox/commands/plans_command/delete_command'

module ThreeScaleToolbox
  module Commands
    module PlansCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'application-plan'
          usage       'application-plan <sub-command> [options]'
          summary     'application-plan super command'
          description 'Application plan commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(Export::ExportSubcommand)
      add_subcommand(Import::ImportSubcommand)
      add_subcommand(Create::CreateSubcommand)
      add_subcommand(Apply::ApplySubcommand)
      add_subcommand(List::ListSubcommand)
      add_subcommand(Show::ShowSubcommand)
      add_subcommand(Delete::DeleteSubcommand)
    end
  end
end
