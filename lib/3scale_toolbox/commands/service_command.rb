require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/service_command/list_command'
require '3scale_toolbox/commands/service_command/show_command'
require '3scale_toolbox/commands/service_command/delete_command'
require '3scale_toolbox/commands/service_command/create_command'
require '3scale_toolbox/commands/service_command/apply_command'


module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      include ThreeScaleToolbox::Command

      def self.command
        Cri::Command.define do
          name        'service'
          usage       'service <sub-command> [options]'
          summary     'services super command'
          description 'Manage your services'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end

      add_subcommand(List::ListSubcommand)
      add_subcommand(Show::ShowSubcommand)
      add_subcommand(Delete::DeleteSubcommand)
      add_subcommand(Create::CreateSubcommand)
      add_subcommand(Apply::ApplySubcommand)
    end
  end
end
