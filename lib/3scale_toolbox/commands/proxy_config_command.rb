require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/proxy_config_command/helper'
require '3scale_toolbox/commands/proxy_config_command/list_command'
require '3scale_toolbox/commands/proxy_config_command/show_command'
require '3scale_toolbox/commands/proxy_config_command/promote_command'
require '3scale_toolbox/commands/proxy_config_command/export_command'
require '3scale_toolbox/commands/proxy_config_command/deploy_command'

module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      include ThreeScaleToolbox::Command

      def self.command
        Cri::Command.define do
          name        'proxy-config'
          usage       'proxy-config <sub-command> [options]'
          summary     'proxy-config super command'
          description 'Manage your Proxy Configurations'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end

      add_subcommand(List::ListSubcommand)
      add_subcommand(Show::ShowSubcommand)
      add_subcommand(Promote::PromoteSubcommand)
      add_subcommand(Export::ExportSubcommand)
      add_subcommand(DeploySubcommand)
    end
  end
end
