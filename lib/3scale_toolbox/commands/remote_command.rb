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
          list_remotes
        rescue StandardError => e
          warn e.message
          exit 1
        end

        def validate_remotes(remotes)
          # TODO
        end

        def list_remotes
          remotes = ThreeScaleToolbox.configuration.data :remotes
          if remotes.nil? || remotes.empty?
            puts 'Emtpy remote list.'
            exit 0
          end

          validate_remotes(remotes)

          remotes.each do |name, remote|
            puts "#{name} #{remote[:endpoint]} #{remote[:provider_key]}"
          end
        end

        add_subcommand(RemoteAddSubcommand)
        add_subcommand(RemoteRemoveSubcommand)
        add_subcommand(RemoteRenameSubcommand)
      end
    end
  end
end
