require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/update_command/update_service'

module ThreeScaleToolbox
  module Commands
    module UpdateCommand
      extend ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'update'
          usage       'update <command> [options]'
          summary     '3scale CLI update'
          description '3scale CLI update tools to manage your API from the terminal.'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end
        end
      end
      add_subcommand(UpdateServiceSubcommand)
    end
  end
end
