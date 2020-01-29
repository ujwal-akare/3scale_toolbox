module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS = %w[id version environment]

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list <remote> <service> <environment>'
              summary     'List Proxy Configurations'
              description 'List all defined Proxy Configurations'

              ThreeScaleToolbox::CLI.output_flag(self)
              param   :remote
              param   :service_ref
              param   :environment

              runner ListSubcommand
            end
          end

          def run
            printer.print_collection service.proxy_configs(proxy_config_environment).map(&:attrs)
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
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
            # keep backwards compatibility
            options.fetch(:output, CLI::CustomTablePrinter.new(FIELDS))
          end
        end
      end
    end
  end
end
