require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/remotes'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRenameSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::Remotes

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
        end

        private

        def validate_remote_old_name(name)
          raise ThreeScaleToolbox::Error, "Could not rename, old name '#{name}' does not exist." unless remotes.key?(name)
        end

        def validate_remote_new_name(name)
          raise ThreeScaleToolbox::Error, "Could not rename, new name '#{name}' already exists." if remotes.key?(name)
        end

        def rename_remote(remote_old_name, remote_new_name)
          validate_remote_old_name remote_old_name
          validate_remote_new_name remote_new_name
          update_remotes do |rmts|
            rmts.tap do |r|
              r[remote_new_name] = r.delete remote_old_name
            end
          end
        end
      end
    end
  end
end
