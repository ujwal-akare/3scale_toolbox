module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      module Show
        class ShowSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'show'
              usage       'show <remote> <service> <environment>'
              summary     'Show Proxy Configuration'
              description 'Show a Proxy Configuration'

              param   :remote
              param   :service_ref
              param   :environment

              ThreeScaleToolbox::CLI.output_flag(self)
              option nil, :'config-version', "Specify the Proxy Configuration version. If not specified it gets the latest version", default: 'latest', argument: :required

              runner ShowSubcommand
            end
          end

          def run
            printer.print_record proxy_config.attrs
          end

          private

          def proxy_config
            if proxy_config_version_option == 'latest'
              proxy_config_latest
            else
              proxy_config_version
            end
          end

          def proxy_config_version
            Entities::ProxyConfig.find(service: service, environment: proxy_config_environment, version: proxy_config_version_option).tap do |pc|
              raise ThreeScaleToolbox::Error, "ProxyConfig #{proxy_config_environment} in service #{service.id} does not exist" if pc.nil?
            end
          end

          def proxy_config_latest
            Entities::ProxyConfig.find_latest(service: service, environment: proxy_config_environment).tap do |pc|
              raise ThreeScaleToolbox::Error, "ProxyConfig #{proxy_config_environment} in service #{service.id} does not exist" if pc.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def proxy_config_version_option
            options[:'config-version']
          end

          def proxy_config_environment
            arguments[:environment]
          end

          def service_ref
            arguments[:service_ref]
          end

          def find_service
            Entities::Service.find(remote: remote, ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def service
            @service ||= find_service
          end

          def printer
            options.fetch(:output, CLI::JsonPrinter.new)
          end
        end
      end
    end
  end
end
