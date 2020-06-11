module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      module Export
        class ExportSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'export'
              usage       'export <remote>'
              summary     'Export proxy configuration for the entire provider account'
              description <<-HEREDOC
              Export proxy configuration for the entire provider account
              \n Can be used as 3scale apicast configuration file
              \n https://github.com/3scale/apicast/blob/master/doc/parameters.md#threescale_config_file
              HEREDOC

              param :remote

              ThreeScaleToolbox::CLI.output_flag(self)
              option nil, :environment, "Gateway environment. Must be 'sandbox' or 'production'", default: 'sandbox', argument: :required, transform: ProxyConfigCommand::EnvironmentTransformer.new

              runner ExportSubcommand
            end
          end

          def run
            printer.print_record proxy_config_list_obj
          end

          private

          def proxy_config_list_obj
            {
              'services' => proxy_config_list
            }
          end

          def proxy_config_list
            service_list.map do |service|
              pc = Entities::ProxyConfig.find_latest(service: service, environment: environment)
              pc.attrs['content'] unless pc.nil?
            end.compact
          end

          def service_list
            tmp_list = remote.list_services

            if tmp_list.respond_to?(:has_key?) && (errors = tmp_list['errors'])
              raise ThreeScaleToolbox::ThreeScaleApiError.new('Service list not read', errors)
            end

            tmp_list.map do |svc_attrs|
              Entities::Service.new(id: svc_attrs.fetch('id'), remote: remote, attrs: svc_attrs)
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def environment
            options[:environment]
          end

          def printer
            options.fetch(:output, CLI::JsonPrinter.new)
          end
        end
      end
    end
  end
end
