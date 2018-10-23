require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/copy_command/copy_service'

module ThreeScaleToolbox
  module Commands
    module CopyCommand
      extend ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'copy'
          usage       'copy <command> [options]'
          summary     '3scale copy command'
          description '3scale copy command.'
        end
      end
      add_subcommand(CopyServiceSubcommand)
    end
  end
end
