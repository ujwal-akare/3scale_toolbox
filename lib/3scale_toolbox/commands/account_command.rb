require '3scale_toolbox/commands/account_command/find_command'

module ThreeScaleToolbox
  module Commands
    module AccountCommand
      include ThreeScaleToolbox::Command

      def self.command
        Cri::Command.define do
          name        'account'
          usage       'acccount <sub-command> [options]'
          summary     'account super command'
          description 'Accounts commands'


          run do |_opts, _args, cmd|
            puts cmd.help
          end

        end
      end
      add_subcommand(Find::FindSubcommand)
    end
  end
end
