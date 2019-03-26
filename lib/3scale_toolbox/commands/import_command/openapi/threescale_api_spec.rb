module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ThreeScaleApiSpec
          attr_reader :openapi

          def initialize(openapi)
            @openapi = openapi
          end

          def title
            openapi.info.title
          end

          def description
            openapi.info.description
          end

          def host
            openapi.host
          end

          def schemes
            Array(openapi.schemes)
          end

          def backend_version
            # default authentication mode if no security requirement
            return '1' if security.nil?

            case security.type
            when 'oauth2'
              'oidc'
            when 'apiKey'
              '1'
            else
              raise ThreeScaleToolbox::Error, "Unexpected security scheme type #{security.type}"
            end
          end

          def security
            @security ||= parse_security
          end

          def operations
            openapi.operations.map do |op|
              Operation.new(
                path: "#{openapi.base_path}#{op.path}",
                verb: op.verb,
                operationId: op.operation_id
              )
            end
          end

          private

          def parse_security
            raise ThreeScaleToolbox::Error, 'Invalid OAS: multiple security requirements' \
              if openapi.global_security_requirements.size > 1

            openapi.global_security_requirements.first
          end
        end
      end
    end
  end
end
