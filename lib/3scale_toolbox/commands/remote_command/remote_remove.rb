module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRemoveSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'remove'
            usage       'remove <name>'
            summary     '3scale CLI remote remove'
            description '3scale CLI command to remove remote'
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
