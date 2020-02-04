module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      class ShowSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        FIELDS = %w[
          id name state system_name end_user_registration_required
          backend_version deployment_option support_email description
          created_at updated_at
        ]

        def self.command
          Cri::Command.define do
            name        'show'
            usage       'show <remote> <service-id_or_system-name>'
            summary     'Show the information of a service'
            description "Show the information of a service"

            ThreeScaleToolbox::CLI.output_flag(self)
            param   :remote
            param   :service_id_or_system_name

            runner ShowSubcommand
          end
        end

        def run
          printer.print_record service.attrs
        end

        private

        def remote
          @remote ||= threescale_client(arguments[:remote])
        end

        def ref
          @ref ||= arguments[:service_id_or_system_name]
        end

        def service
          @service ||= find_service
        end

        def find_service
          Entities::Service::find(remote: remote, ref: ref).tap do |svc|
            raise ThreeScaleToolbox::Error, "Service #{ref} does not exist" if svc.nil?
          end
        end

        def printer
          options.fetch(:output, CLI::CustomTablePrinter.new(FIELDS))
        end
      end
    end
  end
end
