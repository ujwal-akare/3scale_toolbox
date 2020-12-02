require '3scale_toolbox/commands/policies_command/export_command'
require '3scale_toolbox/commands/policies_command/import_command'

module ThreeScaleToolbox
  module Commands
    module PoliciesCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'policies'
          usage       'policies <sub-command> [options]'
          summary     'policies super command'
          description 'Policies commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(ExportSubcommand)
      add_subcommand(ImportSubcommand)
    end
  end
end
