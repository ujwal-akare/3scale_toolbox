require '3scale_toolbox/commands/3scale_command'
require '3scale_toolbox/commands/help_command'
require '3scale_toolbox/commands/copy_command'
require '3scale_toolbox/commands/import_command'
require '3scale_toolbox/commands/update_command'
require '3scale_toolbox/commands/remote_command'

module ThreeScaleToolbox
  module Commands
    BUILTIN_COMMANDS = [ # :nodoc:
      ThreeScaleToolbox::Commands::HelpCommand,
      ThreeScaleToolbox::Commands::CopyCommand,
      ThreeScaleToolbox::Commands::ImportCommand,
      ThreeScaleToolbox::Commands::UpdateCommand,
      ThreeScaleToolbox::Commands::RemoteCommand::RemoteCommand
    ].freeze

    def self.service_valid_params
      %w[
        name backend_version deployment_option description
        system_name end_user_registration_required
        support_email tech_support_email admin_support_email
      ]
    end
  end
end
