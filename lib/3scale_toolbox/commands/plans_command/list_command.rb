module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS_TO_SHOW = %w[id name system_name].freeze

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list [opts] <remote> <service>'
              summary     'list application plans'
              description 'List application plans'

              param       :remote
              param       :service_ref

              runner ListSubcommand
            end
          end

          def run
            print_header
            print_data
          end

          private

          def print_header
            puts FIELDS_TO_SHOW.map(&:upcase).join("\t")
          end

          def print_data
            service.plans.each do |plan|
              puts FIELDS_TO_SHOW.map { |field| plan.fetch(field, '(empty)') }.join("\t")
            end
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end
        end
      end
    end
  end
end
