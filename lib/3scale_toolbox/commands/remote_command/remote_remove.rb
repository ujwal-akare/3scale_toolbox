module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRemoveSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'remove'
            usage       'remove <name>'
            summary     'remote remove'
            description 'Remove remote from list'
            param       :remote_name
            runner RemoteRemoveSubcommand
          end
        end

        def run
          remotes.delete(arguments[:remote_name]) do |el|
            raise ThreeScaleToolbox::Error, "could not remove remote '#{el}'"
          end
        end
      end
    end
  end
end
