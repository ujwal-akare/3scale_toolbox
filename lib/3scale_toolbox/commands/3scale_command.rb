require 'cri'
require '3scale_toolbox/version'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module ThreeScaleCommand
      extend ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        '3scale'
          usage       '3scale <command> [options]'
          summary     '3scale CLI Toolbox'
          description '3scale CLI tools to manage your API from the terminal.'
          required :c, 'config-file', '3scale CLI configuration file' do |val, _cmd|
            ThreeScaleToolbox.config_file = val
          end
          flag :v, :version, 'Prints the version of this command' do |_, _|
            puts ThreeScaleToolbox::VERSION
            exit
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
