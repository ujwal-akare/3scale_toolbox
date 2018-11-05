require 'cri'
require '3scale/api'
require '3scale_toolbox/base_command'
require '3scale_toolbox/remotes'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteAddSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::Remotes

        def self.command
          Cri::Command.define do
            name        'add'
            usage       'add <remote_name> <remote_url>'
            summary     '3scale CLI remote add'
            description '3scale CLI command to add new remote'
            param       :remote_name
            param       :remote_url
            runner RemoteAddSubcommand
          end
        end

        def run
          # 'arguments' cannot be converted to Hash
          add_remote arguments[:remote_name], arguments[:remote_url]
        end

        private

        def validate_remote_name(name)
          raise ThreeScaleToolbox::Error, 'remote name already exists.' if remotes.key?(name)
        end

        def add_remote(remote_name, remote_url)
          validate_remote_name remote_name
          remote = parse_remote_uri remote_url
          validate_remote remote
          update_remotes do |rmts|
            rmts.tap { |r| r[remote_name] = remote }
          end
        end
      end
    end
  end
end
