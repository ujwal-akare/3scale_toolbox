require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteRemoveSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
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
          config.update(:remotes) do |remotes|
            remotes = {} if remotes.nil?
            remotes.tap do |r|
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
