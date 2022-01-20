require '3scale_toolbox/commands/proxy_command/update_command'
require '3scale_toolbox/commands/proxy_command/deploy_command'
require '3scale_toolbox/commands/proxy_command/show_command'

module ThreeScaleToolbox
  module Commands
    module ProxyCommand
      include ThreeScaleToolbox::Command

      def self.command
        Cri::Command.define do
          name        'proxy'
          usage       'proxy <sub-command> [options]'
          summary     'proxy super command'
          description 'APIcast configuration commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end

      add_subcommand(UpdateSubcommand)
      add_subcommand(DeploySubcommand)
      add_subcommand(ShowSubcommand)
    end
  end
end
