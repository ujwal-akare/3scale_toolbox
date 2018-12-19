module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRenameSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'rename'
            usage       'rename <old_name> <new_name>'
            summary     'remote rename'
            description 'Rename remote name'
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
          raise ThreeScaleToolbox::Error, "Could not rename, old name '#{name}' does not exist." unless remotes.all.key?(name)
        end

        def validate_remote_new_name(name)
          raise ThreeScaleToolbox::Error, "Could not rename, new name '#{name}' already exists." if remotes.all.key?(name)
        end

        def rename_remote(remote_old_name, remote_new_name)
          validate_remote_old_name remote_old_name
          validate_remote_new_name remote_new_name
          remotes.add(remote_new_name, remotes.delete(remote_old_name))
        end
      end
    end
  end
end
