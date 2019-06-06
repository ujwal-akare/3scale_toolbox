require '3scale_toolbox/commands/application_command/list_command'
require '3scale_toolbox/commands/application_command/create_command'
require '3scale_toolbox/commands/application_command/show_command'

module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'application'
          usage       'application <sub-command> [options]'
          summary     'application super command'
          description 'application commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(List::ListSubcommand)
      add_subcommand(Create::CreateSubcommand)
      add_subcommand(Show::ShowSubcommand)
    end
  end
end
