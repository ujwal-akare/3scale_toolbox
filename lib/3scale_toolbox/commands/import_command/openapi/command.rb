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
              usage       'openapi [opts] -d <dst> <spec>'
              summary     'Import API defintion in OpenAPI specification'
              description 'Using an API definition format like OpenAPI, import to your 3Scale API'

              option  :d, :destination, '3scale target instance. Format: "http[s]://<authentication>@3scale_domain"', argument: :required
              option  :s, :service, '<service_id> of your 3Scale account', argument: :required
              param   :openapi_file

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

          def load_openapi
            Swagger.load(arguments[:openapi_file])
          end
        end
      end
    end
  end
end
