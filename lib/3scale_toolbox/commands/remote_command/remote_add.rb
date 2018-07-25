require 'cri'
require '3scale/api'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteAddSubcommand < Cri::CommandRunner
        extend ThreeScaleToolbox::Command
        def self.command
          Cri::Command.define do
            name        'add'
            usage       'add <remote_name> <remote_url>'
            summary     '3scale CLI remote add'
            description '3scale CLI command to add new remote'
            runner RemoteAddSubcommand
          end
        end

        def run
          validate_input_params
          begin
            add_remote(*arguments[0..1])
          rescue StandardError => e
            warn e.message
            #warn e.backtrace
            exit 1
          end
        end

        def validate_input_params
          return unless arguments.size != 2
          puts command.help
          exit 0
        end

        def validate_remote_name(name)
          remotes = ThreeScaleToolbox.configuration.data :remotes
          raise 'fatal: remote name already exists.' if !remotes.nil? && remotes.key?(name)
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
            provider_key: provider_key
          )
          begin
            client.list_services
          rescue ThreeScale::API::HttpClient::ForbiddenError
            raise 'fatal: remote authorization failed.'
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
          ThreeScaleToolbox.configuration.update(:remotes) do |remotes|
            remotes = {} if remotes.nil?
            remotes.tap { |r| r[remote_name] = remote }
          end
        end
      end
    end
  end
end
