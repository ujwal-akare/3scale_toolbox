module ThreeScaleToolbox
  module Commands
    module ActiveDocsCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list <remote>'
              summary     'List ActiveDocs'
              description 'List all defined ActiveDocs'

              ThreeScaleToolbox::CLI.output_flag(self)
              param :remote
              option :s, :'service-ref', "Filter the ActiveDocs by Service reference", argument: :required

              runner ListSubcommand
            end
          end

          def run
            printer.print_collection filtered_activedocs
          end

          private

          ACTIVEDOCS_FIELDS_TO_SHOW = %w[
            id name system_name service_id published
            skip_swagger_validations created_at updated_at
          ]

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def printer
            # keep backwards compatibility
            options.fetch(:output, CLI::CustomTablePrinter.new(ACTIVEDOCS_FIELDS_TO_SHOW))
          end

          def service_ref_filter
            options[:'service-ref']
          end

          def filters
            res = []
            if !service_ref_filter.nil?
              res << AttributeFilters::ServiceIDFilterFromServiceRef.new(remote, service_ref_filter, "service_id")
            end
            res
          end

          def filtered_activedocs
            filters.reduce(remote.list_activedocs) do |current_list, filter|
              filter.filter(current_list)
            end
          end
        end
      end
    end
  end
end
