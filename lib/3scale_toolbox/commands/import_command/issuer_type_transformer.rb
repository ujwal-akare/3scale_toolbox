module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        # Helper class to validate values for the oidc-issuer-type argument of the import openapi command
        class IssuerTypeTransformer
          def call(issuer_type)
            raise unless %w[rest keycloak].include?(issuer_type)

            issuer_type
          end
        end
      end
    end
  end
end
