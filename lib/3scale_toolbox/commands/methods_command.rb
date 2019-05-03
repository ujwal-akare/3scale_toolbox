require '3scale_toolbox/commands/methods_command/create_command'
require '3scale_toolbox/commands/methods_command/list_command'
require '3scale_toolbox/commands/methods_command/apply_command'
require '3scale_toolbox/commands/methods_command/delete_command'

module ThreeScaleToolbox
  module Commands
    module MethodsCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'methods'
          usage       'methods <sub-command> [options]'
          summary     'methods super command'
          description 'Methods commands'

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
