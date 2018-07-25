require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRenameSubcommand < Cri::CommandRunner
        extend ThreeScaleToolbox::Command
        def self.command
          Cri::Command.define do
            name        'rename'
            usage       'rename <remote_old_name> <remote_new_name>'
            summary     '3scale CLI remote rename'
            description '3scale CLI command to rename remote name'
            runner RemoteRenameSubcommand
          end
        end

        def run
          validate_input_params
          begin
            rename_remote(*arguments[0..1])
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

        def validate_remote_old_name(name)
          remotes = ThreeScaleToolbox.configuration.data :remotes
          raise "Could not rename, old name '#{name}' does not exist." unless !remotes.nil? && remotes.key?(name)
        end

        def validate_remote_new_name(name)
          remotes = ThreeScaleToolbox.configuration.data :remotes
          raise "Could not rename, new name '#{name}' already exists." if !remotes.nil? && remotes.key?(name)
        end

        def rename_remote(remote_old_name, remote_new_name)
          validate_remote_old_name remote_old_name
          validate_remote_new_name remote_new_name
          ThreeScaleToolbox.configuration.update(:remotes) do |remotes|
            # remotes cannot be nil, already verified
            remotes.tap do |r|
              r[remote_new_name] = r.delete remote_old_name
            end
          end
        end
      end
    end
  end
end
