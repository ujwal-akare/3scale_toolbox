module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class UpdateServiceOidcConfStep
          include Step

          ##
          # Updates OIDC config
          def call
            # setting required attrs, operation is idempotent
            oidc_settings = {}

            add_flow_settings(oidc_settings)

            return unless oidc_settings.size.positive?

            service.update_oidc oidc_settings
            puts 'Service oidc updated'
          end

          private

          def add_flow_settings(settings)
            # only applies to oauth2 sec type
            return if security.nil? || security.type != 'oauth2'

            oidc_configuration = {
              standard_flow_enabled: false,
              implicit_flow_enabled: false,
              service_accounts_enabled: false,
              direct_access_grants_enabled: false
            }.merge(flow => true)
            settings.merge!(oidc_configuration)
          end

          def flow
            case (flow_f = security.flow)
            when 'implicit'
              :implicit_flow_enabled
            when 'password'
              :direct_access_grants_enabled
            when 'application'
              :service_accounts_enabled
            when 'accessCode'
              :standard_flow_enabled
            else
              raise ThreeScaleToolbox::Error, "Unexpected security flow field #{flow_f}"
            end
          end
        end
      end
    end
  end
end
