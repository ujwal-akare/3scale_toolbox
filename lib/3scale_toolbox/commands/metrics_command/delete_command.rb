module ThreeScaleToolbox
  module Commands
    module MetricsCommand
      module Delete
        class DeleteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'delete'
              usage       'delete [opts] <remote> <service> <metric>'
              summary     'delete metric'
              description 'Delete metric'

              param       :remote
              param       :service_ref
              param       :metric_ref

              runner DeleteSubcommand
            end
          end

          def run
            metric.delete
            puts "Metric id: #{metric.id} deleted"
          end

          private

          def service
            @service ||= find_service
          end

          def metric
            @metric ||= find_metric
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def find_metric
            Entities::Metric.find(service: service, ref: metric_ref).tap do |p|
              raise ThreeScaleToolbox::Error, "Metric #{metric_ref} does not exist" if p.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end

          def metric_ref
            arguments[:metric_ref]
          end
        end
      end
    end
  end
end
