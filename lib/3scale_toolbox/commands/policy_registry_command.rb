require '3scale_toolbox/commands/policy_registry_command/copy_command'

module ThreeScaleToolbox
  module Commands
    module PolicyRegistryCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'policy-registry'
          usage       'policy-registry <sub-command> [options]'
          summary     'policy-registry super command'
          description 'Pôlicy Registry commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(Copy::CopySubcommand)
    end
  end
end
