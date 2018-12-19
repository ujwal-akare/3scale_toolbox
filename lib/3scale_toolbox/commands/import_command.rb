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
          usage       'import <sub-command> [options]'
          summary     'import super command'
          description 'Importing 3scale entities'
        end
      end
      add_subcommand(ImportCsvSubcommand)
    end
  end
end
