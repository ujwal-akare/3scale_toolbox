module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module Delete
        class DeleteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'delete'
              usage       'delete <remote> <service-id_or_system-name>'
              summary     'Delete a service'
              description 'Delete a service'
              runner DeleteSubcommand

              param   :remote
              param   :service_id_or_system_name
            end
          end

          def run
            service.delete
            puts "Service with id: #{service.id} deleted"
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
        end
      end
    end
  end
end