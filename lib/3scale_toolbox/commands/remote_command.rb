require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/remotes'
require '3scale_toolbox/commands/remote_command/remote_add'
require '3scale_toolbox/commands/remote_command/remote_remove'
require '3scale_toolbox/commands/remote_command/remote_rename'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteCommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'remote'
            usage       'remote <command> [options]'
            summary     '3scale CLI remotes'
            description '3scale CLI command to manage your remotes'
            runner RemoteCommand
          end
        end

        def run
          list_remotes
        end

        private

        def list_remotes
          if remotes.all.empty?
            puts 'Empty remote list.'
          else
            remotes.all.each do |name, remote|
              puts "#{name} #{remote[:endpoint]} #{remote[:auth_key]}"
            end
          end
        end

        add_subcommand(RemoteAddSubcommand)
        add_subcommand(RemoteRemoveSubcommand)
        add_subcommand(RemoteRenameSubcommand)
      end
    end
  end
end
