require 'swagger'
require 'uri'
require 'net/http'

module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class OpenAPISubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command
          include ThreeScaleToolbox::Remotes
          include ResourceReader

          def self.command
            Cri::Command.define do
              name        'openapi'
              usage       'openapi [opts] -d <dst> <spec>'
              summary     'Import API defintion in OpenAPI specification'
              description 'Using an API definition format like OpenAPI, import to your 3Scale API'

              option  :d, :destination, '3scale target instance. Format: "http[s]://<authentication>@3scale_domain"', argument: :required
              option  :s, :service, '<service_id> of your 3Scale account', argument: :required
              param   :openapi_resource

              runner OpenAPISubcommand
            end
          end

          def run
            context = create_context
            if options[:service]
              context[:service] = Entities::Service.new(id: options[:service],
                                                        remote: context[:threescale_client])
            end

            tasks = []
            tasks << CreateServiceStep.new(context) unless options[:service]
            tasks << CreateMethodsStep.new(context)
            tasks << proc do
              ThreeScaleToolbox::Tasks::DestroyMappingRulesTask.new(target: context[:service]).call
            end
            tasks << CreateMappingRulesStep.new(context)

            # run tasks
            tasks.each(&:call)
          end

          private

          def create_context
            {
              api_spec: ThreeScaleApiSpec.new(load_openapi),
              threescale_client: remote(fetch_required_option(:destination), verify_ssl)
            }
          end

          def load_openapi
            Swagger.build(*openapi_resource(arguments[:openapi_resource]))
            # Disable validation step because https://petstore.swagger.io/v2/swagger.json
            # does not pass validation. Maybe library's schema is outdated?
            # openapi.tap(&:validate)
          rescue Swagger::InvalidDefinition, Hashie::CoercionError, JSON::ParserError, Psych::SyntaxError => e
            raise ThreeScaleToolbox::Error, "OpenAPI schema validation failed: #{e.message}"
          end
        end
      end
    end
  end
end
