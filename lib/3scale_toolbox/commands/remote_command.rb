require 'cri'
require '3scale_toolbox/base_command'
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

        def invalid_remote
          raise "invalid remote configuration from config file #{config_file}"
        end

        def validate_remotes(remotes)
          return if remotes.nil?
          invalid_remote unless remotes.class == Hash
          remotes.each_value do |remote|
            invalid_remote unless remote.key?(:endpoint) && remote.key?(:provider_key)
          end
        end

        def list_remotes
          remotes = config.data :remotes

          validate_remotes(remotes)

          if remotes.nil? || remotes.empty?
            puts 'Emtpy remote list.'
            exit 0
          end

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
