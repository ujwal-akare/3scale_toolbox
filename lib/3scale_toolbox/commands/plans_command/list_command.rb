module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS = %w[id name system_name].freeze

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list [opts] <remote> <service>'
              summary     'list application plans'
              description 'List application plans'

              ThreeScaleToolbox::CLI.output_flag(self)
              param       :remote
              param       :service_ref

              runner ListSubcommand
            end
          end

          def run
            printer.print_collection service.plans.map(&:attrs)
          end

          private

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

          def printer
            # keep backwards compatibility
            options.fetch(:output, CLI::CustomTablePrinter.new(FIELDS))
          end
        end
      end
    end
  end
end
