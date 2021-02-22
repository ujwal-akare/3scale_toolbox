require '3scale_toolbox/commands/product_command/copy_command'
require '3scale_toolbox/commands/product_command/export_command'
require '3scale_toolbox/commands/product_command/import_command'

module ThreeScaleToolbox
  module Commands
    module ProductCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'product'
          usage       'product <sub-command> [options]'
          summary     'product super command'
          description 'Product commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(CopySubcommand)
      add_subcommand(ExportSubcommand)
      add_subcommand(ImportSubcommand)
    end
  end
end
