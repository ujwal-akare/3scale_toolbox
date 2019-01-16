require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/remotes'
require '3scale_toolbox/commands/remote_command/remote_add'
require '3scale_toolbox/commands/remote_command/remote_remove'
require '3scale_toolbox/commands/remote_command/remote_rename'
require '3scale_toolbox/commands/remote_command/remote_list'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteCommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'remote'
            usage       'remote <sub-command> [options]'
            summary     'remotes super command'
            description 'Manage your remotes'
            runner RemoteCommand
          end
        end

        def run
          puts command.help
        end

        add_subcommand(RemoteAddSubcommand)
        add_subcommand(RemoteRemoveSubcommand)
        add_subcommand(RemoteRenameSubcommand)
        add_subcommand(RemoteListSubcommand)
      end
    end
  end
end
