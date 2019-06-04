module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list <remote> <service> <environment>'
              summary     'List Proxy Configurations'
              description 'List all defined Proxy Configurations'
              runner ListSubcommand

              param   :remote
              param   :service_ref
              param   :environment
            end
          end

          def run
            print_proxy_config_data(proxy_configs, PROXYCONFIG_FIELDS_TO_SHOW)
          end

          private

          PROXYCONFIG_FIELDS_TO_SHOW = %w[
            id version environment
          ]

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def proxy_config_environment
            arguments[:environment]
          end

          def service_ref
            arguments[:service_ref]
          end

          def proxy_configs
            @proxyconfigs ||= service.proxy_configs(proxy_config_environment)
          end

          def print_proxy_config_data(proxyconfigs, fields_to_show)
            print_header(fields_to_show)
            print_results(proxyconfigs, fields_to_show)
          end

          def print_header(fields_to_show)
            puts fields_to_show.map{ |e| e.upcase}.join("\t")
          end

          def print_results(proxyconfigs, fields_to_show)
            proxyconfigs.each do |proxyconfig|
              proxy_config_attrs = proxyconfig.attrs
              puts fields_to_show.map { |field| proxy_config_attrs.fetch(field, '(empty)') }.join("\t")
            end
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