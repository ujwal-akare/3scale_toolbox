require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module HelpCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.new_basic_help
      end
    end
  end
end
