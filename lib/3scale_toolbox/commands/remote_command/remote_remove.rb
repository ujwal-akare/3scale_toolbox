require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRemoveSubcommand < Cri::CommandRunner
        extend ThreeScaleToolbox::Command
        def self.command
          Cri::Command.define do
            name        'remove'
            usage       'remove <remote_name>'
            summary     '3scale CLI remote remove'
            description '3scale CLI command to remove remote'
            runner RemoteRemoveSubcommand
          end
        end

        def run
          validate_input_params
          begin
            remove_remote(arguments[0])
          rescue StandardError => e
            warn e.message
            exit 1
          end
        end

        def validate_input_params
          return unless arguments.size != 1
          puts command.help
          exit 0
        end

        def remove_remote(remote_name)
          ThreeScaleToolbox.configuration.update(:remotes) do |remotes|
            remotes = {} if remotes.nil?
            remotes.tap do |r|
              r.delete(remote_name) do |el|
                raise "Could not remove remote '#{el}'"
              end
            end
          end
        end
      end
    end
  end
end
