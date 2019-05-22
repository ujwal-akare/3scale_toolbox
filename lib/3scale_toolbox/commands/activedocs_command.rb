require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/activedocs_command/delete_command'
require '3scale_toolbox/commands/activedocs_command/create_command'
require '3scale_toolbox/commands/activedocs_command/apply_command'
require '3scale_toolbox/commands/activedocs_command/list_command'

module ThreeScaleToolbox
  module Commands
    module ActiveDocsCommand
      include ThreeScaleToolbox::Command

      def self.command
        Cri::Command.define do
          name        'activedocs'
          usage       'activedocs <sub-command> [options]'
          summary     'activedocs super command'
          description 'Manage your ActiveDocs'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end

      add_subcommand(Delete::DeleteSubcommand)
      add_subcommand(Create::CreateSubcommand)
      add_subcommand(Apply::ApplySubcommand)
      add_subcommand(List::ListSubcommand)
    end
  end
end
