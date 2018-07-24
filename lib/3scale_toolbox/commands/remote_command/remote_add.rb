require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteAddSubcommand < Cri::CommandRunner
        extend ThreeScaleToolbox::Command
        def self.command
          Cri::Command.define do
            name        'add'
            usage       'add <remote_name> <remote_url>'
            summary     '3scale CLI remote add'
            description '3scale CLI command to add new remote'
            runner RemoteAddSubcommand
          end
        end

        def run
          validate_input_params
          begin
            add_remote(*arguments[0..1])
          rescue StandardError => e
            warn e.message
            exit 1
          end
        end

        def validate_input_params
          return unless arguments.size != 2
          puts command.help
          exit 0
        end

        def validate_remote_name(name)
          remotes = ThreeScaleToolbox.configuration.remotes
          raise 'fatal: remote name already exists.' if remotes.key? name
        end

        def validate_remote_url(remote_url)
          # TODO
        end

        def add_remote(remote_name, remote_url)
          validate_remote_name remote_name
          validate_remote_url remote_url
          ThreeScaleToolbox.configuration.update_remotes do |remotes|
            remotes[remote_name] = remote_url
          end
        end
      end
    end
  end
end
