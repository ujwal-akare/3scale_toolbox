module ThreeScaleToolbox
  module Commands
    module ProxyCommand
      class UpdateSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        class ProxyParamTransformer
          def call(param_str)
            params = param_str.split('=', 2)

            raise ArgumentError unless params.compact.length == 2

            raise ArgumentError unless !params[0].empty? && !params[1].empty?

            { params[0] => params[1] }
          end
        end

        def self.command
          Cri::Command.define do
            name        'update'
            usage       'update <remote> <service>'
            summary     'Update APIcast configuration'
            description 'Update APIcast configuration'

            param :remote
            param :service_ref

            ThreeScaleToolbox::CLI.output_flag(self)
            option :p, :param, 'APIcast configuration parameters. Format: [--param key=value]. Multiple options allowed. ', argument: :required, multiple: true, transform: ProxyParamTransformer.new

            runner UpdateSubcommand
          end
        end

        def run
          raise ThreeScaleToolbox::Error, 'APIcast configuration parameters required' if proxy_attrs.empty?

          printer.print_record(service.update_proxy(proxy_attrs))
        end

        private

        def remote
          @remote ||= threescale_client(arguments[:remote])
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

        def proxy_attrs
          (options[:param] || []).inject({}) do |acc, s|
            acc.merge!(s)
          end
        end

        def printer
          options.fetch(:output, CLI::JsonPrinter.new)
        end
      end
    end
  end
end
