require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/copy_command/copy_service'

module ThreeScaleToolbox
  module Commands
    module CopyCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'copy'
          usage       'copy <sub-command> [options]'
          summary     'copy super command'
          description 'Copy 3scale entities between tenants'
        end
      end
      add_subcommand(CopyServiceSubcommand)
    end
  end
end
