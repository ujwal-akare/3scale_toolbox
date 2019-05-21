module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module Show
        class ShowSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'show'
              usage       'service show <remote> <service-id_or_system-name>'
              summary     'Show the information of a service'
              description "Show the information of a service"
              runner ShowSubcommand

              param   :remote
              param   :service_id_or_system_name
            end
          end

          def run
            print_header
            print_data
          end

          private

          SERVICE_FIELDS_TO_SHOW = %w[
            id name state system_name end_user_registration_required
            backend_version deployment_option support_email description
            created_at updated_at
          ]

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

          def print_header
            puts SERVICE_FIELDS_TO_SHOW.map{|e| e.upcase}.join("\t")
          end

          def print_data
              puts SERVICE_FIELDS_TO_SHOW.map{|field| service.attrs.fetch(field, '(empty)')}.join("\t")
          end
        end
      end
    end
  end
end
