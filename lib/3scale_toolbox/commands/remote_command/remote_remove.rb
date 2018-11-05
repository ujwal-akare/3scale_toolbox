require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/remotes'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRemoveSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::Remotes

        def self.command
          Cri::Command.define do
            name        'remove'
            usage       'remove <remote_name>'
            summary     '3scale CLI remote remove'
            description '3scale CLI command to remove remote'
            param       :remote_name
            runner RemoteRemoveSubcommand
          end
        end

        def run
          # 'arguments' cannot be converted to Hash
          remove_remote arguments[:remote_name]
        end

        private

        def remove_remote(remote_name)
          update_remotes do |rmts|
            rmts.tap do |r|
              r.delete(remote_name) do |el|
                raise ThreeScaleToolbox::Error, "could not remove remote '#{el}'"
              end
            end
          end
        end
      end
    end
  end
end
