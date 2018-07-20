require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/remote_command/remote_add'
require '3scale_toolbox/commands/remote_command/remote_remove'
require '3scale_toolbox/commands/remote_command/remote_rename'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteCommand < Cri::CommandRunner
        extend ThreeScaleToolbox::Command
        def self.command
          Cri::Command.define do
            name        'remote'
            usage       'remote <command> [options]'
            summary     '3scale CLI remote'
            description '3scale CLI command to manage your remotes'
            runner RemoteCommand
          end
        end

        def run
          # list remotes
          puts "list remotes"
        end

        add_subcommand(RemoteAddSubcommand)
        add_subcommand(RemoteRemoveSubcommand)
        add_subcommand(RemoteRenameSubcommand)
      end
    end
  end
end
