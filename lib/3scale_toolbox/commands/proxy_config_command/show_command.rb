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
              runner ShowSubcommand

              param   :remote
              param   :service_ref
              param   :environment

              option nil, :'config-version', "Specify the Proxy Configuration version. If not specified it gets the latest version", argument: :required
            end
          end

          def run      
            print_proxy_config
          end

          private

          def proxy_config
            @proxy_config ||= find_proxy_config 
          end

          def find_proxy_config
            if proxy_config_version == "latest"
              find_proxy_config_latest
            else
              find_proxy_config_version
            end
          end

          def find_proxy_config_version
            Entities::ProxyConfig.find(service: service, environment: proxy_config_environment, version: proxy_config_version).tap do |pc|
              raise ThreeScaleToolbox::Error, "ProxyConfig #{proxy_config_environment} in service #{service.id} does not exist" if pc.nil?
            end
          end

          def find_proxy_config_latest
            Entities::ProxyConfig.find_latest(service: service, environment: proxy_config_environment).tap do |pc|
              raise ThreeScaleToolbox::Error, "ProxyConfig #{proxy_config_environment} in service #{service.id} does not exist" if pc.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def proxy_config_version
            options[:'config-version'] || "latest"
          end

          def proxy_config_environment
            arguments[:environment]
          end

          def print_proxy_config
            puts JSON.pretty_generate(proxy_config.attrs)    
          end

          def service_ref
            arguments[:service_ref]
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def service
            @service ||= find_service
          end
        end
      end
    end
  end
end