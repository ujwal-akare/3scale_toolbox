require 'swagger'

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
              usage       'openapi [opts] -d <dst> --service <serviceId> <oas resource>'
              summary     'Import API defintion in OpenAPI specification'
              description 'Using an API definition format like OpenAPI, import to your 3Scale API'

              option  :d, :destination, '3scale target instance. Format: "http[s]://<provider_key>@3scale_url"', argument: :required
              option  :s, :service, 'SERVICE_ID of your 3Scale account', argument: :required
              param   :openapi_file

              runner OpenAPISubcommand
            end
          end

          def run
            threescale_api_spec = ThreeScaleApiSpec.generate(parse_openapi)
            service = remote_service
            [
              CreateMethodsStep.new(api_spec: threescale_api_spec, service: service),
              CreateMappingRulesStep.new(api_spec: threescale_api_spec, service: service)
            ].each(&:call)
          end

          private

          def parse_openapi
            OpenAPIParser.new(load_openapi)
          end

          def load_openapi
            Swagger.load(arguments[:openapi_file])
          end

          def remote_service
            Entities::Service.new(
              id: fetch_required_option(:service),
              remote: remote(fetch_required_option(:destination), verify_ssl)
            )
          end
        end
      end
    end
  end
end
