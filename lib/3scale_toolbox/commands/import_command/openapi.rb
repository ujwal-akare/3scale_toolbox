require '3scale_toolbox/commands/import_command/openapi/method'
require '3scale_toolbox/commands/import_command/openapi/mapping_rule'
require '3scale_toolbox/commands/import_command/openapi/operation'
require '3scale_toolbox/commands/import_command/openapi/step'
require '3scale_toolbox/commands/import_command/openapi/create_method_step'
require '3scale_toolbox/commands/import_command/openapi/create_backend_method_step'
require '3scale_toolbox/commands/import_command/openapi/create_mapping_rule_step'
require '3scale_toolbox/commands/import_command/openapi/create_backend_mapping_rule_step'
require '3scale_toolbox/commands/import_command/openapi/create_backend_step'
require '3scale_toolbox/commands/import_command/openapi/create_service_step'
require '3scale_toolbox/commands/import_command/openapi/create_activedocs_step'
require '3scale_toolbox/commands/import_command/openapi/update_service_proxy_step'
require '3scale_toolbox/commands/import_command/openapi/update_service_oidc_conf_step'
require '3scale_toolbox/commands/import_command/openapi/update_policies_step'
require '3scale_toolbox/commands/import_command/issuer_type_transformer'
require '3scale_toolbox/commands/import_command/import_product_step'
require '3scale_toolbox/commands/import_command/import_backend_step'

module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class OpenAPISubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command
          include ThreeScaleToolbox::ResourceReader

          def self.command
            Cri::Command.define do
              name        'openapi'
              usage       'openapi [opts] -d <destination> <spec> (/path/to/your/spec/file.[json|yaml|yml] OR http[s]://domain/resource/path.[json|yaml|yml])'
              summary     'Import API defintion in OpenAPI specification from a local file or URL'
              description 'Using an API definition format like OpenAPI, import to your 3scale API directly from a local OpenAPI spec compliant file or a remote URL'

              option  :d, :destination, '3scale target instance. Format: "http[s]://<authentication>@3scale_domain"', argument: :required
              option  :t, 'target_system_name', 'Target system name', argument: :required
              flag    nil, 'activedocs-hidden', 'Create ActiveDocs in hidden state'
              flag    nil, 'skip-openapi-validation', 'Skip OpenAPI schema validation'
              flag    nil, 'prefix-matching', 'Use prefix matching instead of strict matching on mapping rules derived from openapi operations'
              flag    nil, 'backend', 'Create backend API from OAS'
              option  nil, 'oidc-issuer-type', 'OIDC Issuer Type (rest, keycloak)', argument: :required, transform: IssuerTypeTransformer.new
              option  nil, 'oidc-issuer-endpoint', 'OIDC Issuer Endpoint', argument: :required
              option  nil, 'default-credentials-userkey', 'Default credentials policy userkey', argument: :required
              option  nil, 'override-private-basepath', 'Override the basepath for the private URLs', argument: :required
              option  nil, 'override-public-basepath', 'Override the basepath for the public URLs', argument: :required
              option  nil, 'staging-public-base-url', 'Custom public staging URL', argument: :required
              option  nil, 'production-public-base-url', 'Custom public production URL', argument: :required
              option  nil, 'override-private-base-url', 'Custom private base URL', argument: :required
              option nil, 'backend-api-secret-token', 'Custom secret token sent by the API gateway to the backend API',argument: :required
              option nil, 'backend-api-host-header', 'Custom host header sent by the API gateway to the backend API', argument: :required
              ThreeScaleToolbox::CLI.output_flag(self)
              param   :openapi_resource

              runner OpenAPISubcommand
            end
          end

          def run
            if backend?
              ImportBackendStep.new(context).call
            else
              ImportProductStep.new(context).call
            end

            printer.print_record context.fetch(:report)
          end

          private

          def context
            @context ||= create_context
          end

          def create_context
            {
              api_spec_resource: openapi_resource,
              api_spec: openapi_parser,
              threescale_client: threescale_client(fetch_required_option(:destination)),
              target_system_name: options[:target_system_name],
              activedocs_published: !options[:'activedocs-hidden'],
              oidc_issuer_type: options[:'oidc-issuer-type'],
              oidc_issuer_endpoint: options[:'oidc-issuer-endpoint'],
              default_credentials_userkey: options[:'default-credentials-userkey'],
              skip_openapi_validation: options[:'skip-openapi-validation'],
              override_private_basepath: options[:'override-private-basepath'],
              override_public_basepath: options[:'override-public-basepath'],
              production_public_base_url: options[:'production-public-base-url'],
              staging_public_base_url: options[:'staging-public-base-url'],
              override_private_base_url: options[:'override-private-base-url'],
              backend_api_secret_token: options[:'backend-api-secret-token'],
              backend_api_host_header: options[:'backend-api-host-header'],
              prefix_matching: options[:'prefix-matching'],
              delete_mapping_rules: true,
              logger: logger,
            }
          end

          def openapi_resource
            @openapi_resource ||= load_resource(openapi_path)
          end

          def openapi_path
            arguments[:openapi_resource]
          end

          def backend?
            options[:backend]
          end

          def validate
            !options[:'skip-openapi-validation']
          end

          def openapi_parser
            raise ThreeScaleToolbox::Error, 'only JSON/YAML format is supported' unless openapi_resource.is_a?(Hash)

            if openapi_resource.key?('openapi')
              ThreeScaleToolbox::OpenAPI::OAS3.build(openapi_path, openapi_resource, validate: validate)
            else
              ThreeScaleToolbox::OpenAPI::Swagger.build(openapi_resource, validate: validate)
            end
          rescue JSON::Schema::ValidationError => e
            raise ThreeScaleToolbox::Error, "OpenAPI schema validation failed: #{e.message}"
          end

          def printer
            # if product import AND output not specified -> logger
            # if product import AND output specified -> specified printer
            # if backend import AND output not specified -> json printer
            # if backend import AND output specified -> specified printer
            default_printer = if backend?
                                CLI::JsonPrinter.new
                              else
                                CLI::NullPrinter.new
                              end
            options.fetch(:output, default_printer)
          end

          def logger
            if options[:output].nil?
              Logger.new($stdout).tap do |logger|
                logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
              end
            else
              Logger.new(File::NULL)
            end
          end
        end
      end
    end
  end
end
