require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRenameSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        def self.command
          Cri::Command.define do
            name        'rename'
            usage       'rename <remote_old_name> <remote_new_name>'
            summary     '3scale CLI remote rename'
            description '3scale CLI command to rename remote name'
            param       :remote_old_name
            param       :remote_new_name
            runner RemoteRenameSubcommand
          end
        end

        def run
          # 'arguments' cannot be converted to Hash
          rename_remote arguments[:remote_old_name], arguments[:remote_new_name]
        rescue StandardError => e
          warn e.message
          exit 1
        end

        def validate_remote_old_name(name)
          remotes = config.data :remotes
          raise "Could not rename, old name '#{name}' does not exist." unless !remotes.nil? && remotes.key?(name)
        end

        def validate_remote_new_name(name)
          remotes = config.data :remotes
          raise "Could not rename, new name '#{name}' already exists." if !remotes.nil? && remotes.key?(name)
        end

        def rename_remote(remote_old_name, remote_new_name)
          validate_remote_old_name remote_old_name
          validate_remote_new_name remote_new_name
          config.update(:remotes) do |remotes|
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
