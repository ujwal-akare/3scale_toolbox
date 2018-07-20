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
          puts "remote add"
        end
      end
    end
  end
end
