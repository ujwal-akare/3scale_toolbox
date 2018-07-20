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
          puts "remote remove"
        end
      end
    end
  end
end
