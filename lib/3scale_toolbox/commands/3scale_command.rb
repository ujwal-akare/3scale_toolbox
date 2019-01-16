require 'cri'
require '3scale_toolbox/version'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module ThreeScaleCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        '3scale'
          usage       '3scale <sub-command> [options]'
          summary     '3scale toolbox'
          description '3scale toolbox to manage your API from the terminal.'
          option :c, 'config-file', '3scale toolbox configuration file',
            argument: :required, default: ThreeScaleToolbox.default_config_file
          flag :v, :version, 'Prints the version of this command' do
            puts ThreeScaleToolbox::VERSION
            exit 0
          end
          flag :k, :insecure, 'Proceed and operate even for server connections otherwise considered insecure'
          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end
        end
      end
    end
  end
end
