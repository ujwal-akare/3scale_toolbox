require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/update_command/update_service'

module ThreeScaleToolbox
  module Commands
    module UpdateCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'update'
          usage       'update <sub-command> [options]'
          summary     'update super command'
          description 'Update 3scale entities between tenants'
        end
      end
      add_subcommand(UpdateServiceSubcommand)
    end
  end
end
