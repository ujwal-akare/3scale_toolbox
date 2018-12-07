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
            tasks << CreateMappingRulesStep.new(context)

            # run tasks
            tasks.each(&:call)
          end

          private

          def create_context
            {
              api_spec: ThreeScaleApiSpec.parse(load_openapi),
              threescale_client: remote(fetch_required_option(:destination), verify_ssl)
            }
          end

          def openapi_resource
            openapi_detect_resource.call
          end

          def openapi_detect_resource
            case arguments[:openapi_resource]
            when '-'
              method(:openapi_stdin_resource)
            when /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
              method(:openapi_url_resource)
            else
              method(:openapi_file_resource)
            end
          end

          # Detect format from file extension
          def openapi_file_resource
            ext = File.extname arguments[:openapi_resource]
            [File.read(arguments[:openapi_resource]), { format: ext }]
          end

          def openapi_stdin_resource
            content = STDIN.read
            # will try parse json, otherwise yaml
            format = :json
            begin
              JSON.parse(content)
            rescue JSON::ParserError
              format = :yaml
            end
            [content, { format: format }]
          end

          def openapi_url_resource
            uri = URI.parse(arguments[:openapi_resource])
            [Net::HTTP.get(uri), { format: File.extname(uri.path) }]
          end

          def load_openapi
            Swagger.build(*openapi_resource)
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
