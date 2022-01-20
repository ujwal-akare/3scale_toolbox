module ThreeScaleToolbox
  module Commands
    module ProxyCommand
      class ShowSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'show'
            usage       'show <remote> <service>'
            summary     'Fetch (undeployed) APIcast configuration'
            description 'Fetch (undeployed) APIcast configuration'

            param :remote
            param :service_ref

            ThreeScaleToolbox::CLI.output_flag(self)

            runner ShowSubcommand
          end
        end

        def run
          printer.print_record service.proxy
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

        def printer
          options.fetch(:output, CLI::JsonPrinter.new)
        end
      end
    end
  end
end
