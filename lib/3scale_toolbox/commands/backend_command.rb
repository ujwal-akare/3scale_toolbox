require '3scale_toolbox/commands/backend_command/copy_command'

module ThreeScaleToolbox
  module Commands
    module BackendCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'backend'
          usage       'backend <sub-command> [options]'
          summary     'backend super command'
          description 'Backend commands'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(CopySubcommand)
    end
  end
end
