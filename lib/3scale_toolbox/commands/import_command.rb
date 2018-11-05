require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/import_command/import_csv'

module ThreeScaleToolbox
  module Commands
    module ImportCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'import'
          usage       'import <command> [options]'
          summary     '3scale import command'
          description '3scale import command.'
        end
      end
      add_subcommand(ImportCsvSubcommand)
    end
  end
end
