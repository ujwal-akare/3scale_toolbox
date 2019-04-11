module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Delete
        class DeleteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'delete'
              usage       'delete [opts] <remote> <service> <plan>'
              summary     'delete application plan'
              description 'Delete application plan'

              param       :remote
              param       :service_ref
              param       :plan_ref

              runner DeleteSubcommand
            end
          end

          def run
            plan.delete
            puts "Application plan id: #{plan.id} deleted"
          end

          private

          def service
            @service ||= find_service
          end

          def plan
            @plan ||= find_plan
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def find_plan
            Entities::ApplicationPlan.find(service: service, ref: plan_ref).tap do |p|
              raise ThreeScaleToolbox::Error, "Application plan #{plan_ref} does not exist" if p.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end

          def plan_ref
            arguments[:plan_ref]
          end
        end
      end
    end
  end
end
