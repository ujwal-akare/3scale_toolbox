require '3scale_toolbox/commands/3scale_command'
require '3scale_toolbox/commands/help_command'
require '3scale_toolbox/commands/copy_command'
require '3scale_toolbox/commands/import_command'
require '3scale_toolbox/commands/update_command'

module ThreeScaleToolbox
  module Commands
    BUILTIN_COMMANDS = [ # :nodoc:
      ThreeScaleToolbox::Commands::HelpCommand,
      ThreeScaleToolbox::Commands::CopyCommand,
      ThreeScaleToolbox::Commands::ImportCommand,
      ThreeScaleToolbox::Commands::UpdateCommand
    ].freeze
  end
end
