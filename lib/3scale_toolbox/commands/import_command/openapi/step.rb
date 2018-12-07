module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module Step
          attr_reader :context

          def initialize(context)
            @context = context
          end

          # Can be nil on initialization time and not nil afterwards
          # method to fetch from context required
          def service
            context[:service]
          end

          def api_spec
            context[:api_spec]
          end

          def threescale_client
            context[:threescale_client]
          end

          def operations
            context[:operations]
          end
        end
      end
    end
  end
end
