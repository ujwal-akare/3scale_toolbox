module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list <remote>'
              summary     'List all services'
              description 'List all services'
              runner ListSubcommand

              param   :remote
            end
          end

          def run
            print_header
            print_data
          end

          private

          SERVICE_FIELDS_TO_SHOW = %w[id name system_name]

          def services
            @services ||= remote.list_services()
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def print_header
            puts SERVICE_FIELDS_TO_SHOW.map{|e| e.upcase}.join("\t")
          end

          def print_data
            services.each do |service|
              puts SERVICE_FIELDS_TO_SHOW.map{|field| service.fetch(field, '(empty)')}.join("\t")
            end
          end
        end
      end
    end
  end
end
