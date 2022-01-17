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

            res = service.update_oidc oidc_settings
            if (errors = res['errors'])
              raise ThreeScaleToolbox::Error, "Service oidc has not been updated. #{errors}"
            end

            logger.info 'Service oidc updated'
          end

          private

          def add_flow_settings(settings)
            # only applies to oauth2 sec type
            return if api_spec.security.nil? || api_spec.security[:type] != 'oauth2'

            oidc_configuration = {
              standard_flow_enabled: false,
              implicit_flow_enabled: false,
              service_accounts_enabled: false,
              direct_access_grants_enabled: false
            }.merge(api_spec.security[:flow] => true)
            settings.merge!(oidc_configuration)
          end
        end
      end
    end
  end
end
