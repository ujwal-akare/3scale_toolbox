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
              runner ListSubcommand

              param :remote
              option :s, :'service-ref', "Filter the ActiveDocs by Service reference", argument: :required
            end
          end

          def run
            activedocs = remote.list_activedocs
            print_activedocs_data(activedocs, ACTIVEDOCS_FIELDS_TO_SHOW)
          end

          private

          ACTIVEDOCS_FIELDS_TO_SHOW = %w[
            id name system_name service_id published
            skip_swagger_validations created_at updated_at
          ]

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def print_activedocs_data(activedocs, fields_to_show)
            print_header(fields_to_show)
            print_results(activedocs, fields_to_show)
          end

          def print_header(fields_to_show)
            puts fields_to_show.map { |e| e.upcase }.join("\t")
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

          def filtered_activedocs(activedocs)
            filters.reduce(activedocs) { |current_list, filter| filter.filter(current_list) }
          end

          def print_results(activedocs, fields_to_show)
            filtered_activedocs(activedocs).each do |activedoc|
              puts fields_to_show.map { |field| activedoc.fetch(field, '(empty)') }.join("\t")
            end
          end
        end
      end
    end
  end
end
