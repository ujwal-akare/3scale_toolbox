module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS = %w[id name system_name]

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list <remote>'
              summary     'List all services'
              description 'List all services'

              ThreeScaleToolbox::CLI.output_flag(self)
              param :remote

              runner ListSubcommand
            end
          end

          def run
            printer.print_collection remote.list_services
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
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
