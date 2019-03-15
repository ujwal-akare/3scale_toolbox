require '3scale_toolbox/commands/import_command/openapi/method'
require '3scale_toolbox/commands/import_command/openapi/mapping_rule'
require '3scale_toolbox/commands/import_command/openapi/operation'
require '3scale_toolbox/commands/import_command/openapi/step'
require '3scale_toolbox/commands/import_command/openapi/resource_reader'
require '3scale_toolbox/commands/import_command/openapi/threescale_api_spec'
require '3scale_toolbox/commands/import_command/openapi/create_method_step'
require '3scale_toolbox/commands/import_command/openapi/create_mapping_rule_step'
require '3scale_toolbox/commands/import_command/openapi/create_service_step'
require '3scale_toolbox/commands/import_command/openapi/create_activedocs_step'

module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class OpenAPISubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command
          include ResourceReader

          def self.command
            Cri::Command.define do
              name        'openapi'
              usage       'openapi [opts] -d <dst> <spec>'
              summary     'Import API defintion in OpenAPI specification'
              description 'Using an API definition format like OpenAPI, import to your 3scale API'

              option  :d, :destination, '3scale target instance. Format: "http[s]://<authentication>@3scale_domain"', argument: :required
              option  :t, 'target_system_name', 'Target system name', argument: :required
              flag    nil, 'activedocs-hidden', 'Create ActiveDocs in hidden state'
              param   :openapi_resource

              runner OpenAPISubcommand
            end
          end

          def run
            tasks = []
            tasks << CreateServiceStep.new(context)
            tasks << CreateMethodsStep.new(context)
            tasks << ThreeScaleToolbox::Tasks::DestroyMappingRulesTask.new(context)
            tasks << CreateMappingRulesStep.new(context)
            tasks << CreateActiveDocsStep.new(context)

            # run tasks
            tasks.each(&:call)
          end

          private

          def context
            @context ||= create_context
          end

          def create_context
            openapi_resource = load_resource(arguments[:openapi_resource])
            {
              api_spec_resource: openapi_resource,
              api_spec: ThreeScaleApiSpec.new(load_openapi(openapi_resource)),
              threescale_client: threescale_client(fetch_required_option(:destination)),
              target_system_name: options[:target_system_name],
              activedocs_published: !options[:'activedocs-hidden']
            }
          end

          def load_openapi(openapi_resource)
            Swagger.build(openapi_resource)
          rescue JSON::Schema::ValidationError => e
            raise ThreeScaleToolbox::Error, "OpenAPI schema validation failed: #{e.message}"
          end
        end
      end
    end
  end
end
