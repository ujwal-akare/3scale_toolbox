module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module Step
          attr_reader :service, :api_spec

          def initialize(service:, api_spec:)
            @service = service
            @api_spec = api_spec
          end
        end
      end
    end
  end
end
