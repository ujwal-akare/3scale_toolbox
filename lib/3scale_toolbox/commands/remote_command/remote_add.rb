require 'cri'
require '3scale/api'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteAddSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
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
          remotes = config.data :remotes
          raise ThreeScaleToolbox::Error, 'remote name already exists.' if !remotes.nil? && remotes.key?(name)
        end

        def parse_remote_uri(remote_url_str)
          # should raise error on invalid urls
          remote_uri_obj = URI(remote_url_str)
          provider_key = remote_uri_obj.user
          remote_uri_obj.user = ''
          endpoint = remote_uri_obj.to_s
          { provider_key: provider_key, endpoint: endpoint }
        end

        def validate_remote_authentication(endpoint:, provider_key:)
          client = ThreeScale::API.new(
            endpoint: endpoint,
            provider_key: provider_key,
            verify_ssl: verify_ssl
          )
          begin
            client.list_services
          rescue ThreeScale::API::HttpClient::ForbiddenError
            raise ThreeScaleToolbox::Error, 'remote not valid'
          end
        end

        def validate_remote_url(remote_url)
          parse_remote_uri(remote_url).tap do |remote|
            validate_remote_authentication(remote)
          end
        end

        def add_remote(remote_name, remote_url)
          validate_remote_name remote_name
          remote = validate_remote_url remote_url
          config.update(:remotes) do |remotes|
            remotes = {} if remotes.nil?
            remotes.tap { |r| r[remote_name] = remote }
          end
        end
      end
    end
  end
end
