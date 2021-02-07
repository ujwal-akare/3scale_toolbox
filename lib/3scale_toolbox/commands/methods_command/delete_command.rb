module ThreeScaleToolbox
  module Commands
    module MethodsCommand
      module Delete
        class DeleteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'delete'
              usage       'delete [opts] <remote> <service> <method>'
              summary     'delete method'
              description 'Delete method'

              param       :remote
              param       :service_ref
              param       :method_ref

              runner DeleteSubcommand
            end
          end

          def run
            method.delete
            puts "Method id: #{method.id} deleted"
          end

          private

          def service
            @service ||= find_service
          end

          def method
            @method ||= find_method
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def find_method
            hits = service.hits
            Entities::Method.find(service: service, ref: method_ref).tap do |p|
              raise ThreeScaleToolbox::Error, "Method #{method_ref} does not exist" if p.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end

          def method_ref
            arguments[:method_ref]
          end
        end
      end
    end
  end
end
