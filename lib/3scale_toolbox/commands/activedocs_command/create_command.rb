module ThreeScaleToolbox
  module Commands
    module ActiveDocsCommand
      module Create
        class CustomPrinter
          def print_record(activedocs)
            puts "ActiveDocs '#{activedocs['name']}' has been created with ID: #{activedocs['id']}"
          end

          def print_collection(collection) end
        end

        class CreateSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command
          include ThreeScaleToolbox::ResourceReader

          def self.command
            Cri::Command.define do
              name        'create'
              usage       'create <remote> <activedocs-name> <spec>'
              summary     'Create an ActiveDocs'
              description 'Create an ActiveDocs'

              option :i, :'service-id', "Specify the Service ID associated to the ActiveDocs", argument: :required
              option :p, :'published', "Specify it to publish the ActiveDoc on the Developer Portal. Otherwise it will be hidden", argument: :forbidden
              option nil, :'skip-swagger-validations', "Specify it to skip validation of the Swagger specification", argument: :forbidden
              option :d, :'description', "Specify the description of the ActiveDocs", argument: :required
              option :s, :'system-name', "Specify the system-name of the ActiveDocs", argument: :required
              ThreeScaleToolbox::CLI.output_flag(self)

              param   :remote
              param   :activedocs_name
              param   :activedocs_spec

              runner CreateSubcommand
            end
          end

          def run
            res = Entities::ActiveDocs.create(remote: remote, attrs: activedocs_attrs)
            printer.print_record res.attrs
          end

          private

          def activedocs_name
            arguments[:activedocs_name]
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def activedocs_json_spec
            activedoc_spec = arguments[:activedocs_spec]
            activedoc_spec_content = load_resource(arguments[:activedocs_spec])
            JSON.pretty_generate(activedoc_spec_content)
          end

          def activedocs_attrs
            {
              "service_id" => options[:'service-id'],
              "published" => options[:'published'],
              "skip_swagger_validations" => options[:'skip-swagger-validations'],
              "description" => options[:'description'],
              "system_name" => options[:'system-name'],
              "name" => activedocs_name,
              "body" => activedocs_json_spec,
            }.compact
          end

          def printer
            # keep backwards compatibility
            options.fetch(:output, CustomPrinter.new)
          end
        end
      end
    end
  end
end
