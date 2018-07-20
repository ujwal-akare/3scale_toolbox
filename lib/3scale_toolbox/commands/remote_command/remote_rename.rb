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
          puts "remote rename"
        end
      end
    end
  end
end
