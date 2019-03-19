module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class UpdatePoliciesStep
          include Step

          ##
          # Updates Proxy Policies config
          def call
            # to be idempotent, we must read first
            source_policies_settings = service.policies
            # shallow copy
            # to detect policies_settings changes, should only be updated setting objects
            # do not update in-place, otherwise changes will not be detected
            policies_settings = source_policies_settings.dup

            add_anonymous_access_policy(policies_settings)
            add_rh_sso_keycloak_role_check_policy(policies_settings)

            return if source_policies_settings == policies_settings

            service.update_policies('policies_config' => policies_settings)
          end

          private

          def add_anonymous_access_policy(policies)
            # only on 'open api' security req
            return unless security.nil?

            return if policies.any? { |policy| policy['name'] == 'default_credentials' }

            # Anonymous policy should be before apicast policy
            # hence, adding as a first element
            policies.insert(0, anonymous_policy)
          end

          def anonymous_policy
            raise ThreeScaleToolbox::Error, 'User key must be provided by ' \
              '--default-credentials-userkey optional param' \
              if default_credentials_userkey.nil?

            {
              'name': 'default_credentials',
              'version': 'builtin',
              'configuration': {
                'auth_type': 'user_key',
                'user_key': default_credentials_userkey
              },
              'enabled': true
            }
          end

          def add_rh_sso_keycloak_role_check_policy(policies)
            # only applies to oauth2 sec type
            return if security.nil? || security.type != 'oauth2'

            return if policies.any? { |policy| policy['name'] == 'keycloak_role_check' }

            policies << keycloak_policy
          end

          def keycloak_policy
            {
              'name': 'keycloak_role_check',
              'version': 'builtin',
              'configuration': {
                'type': 'whitelist',
                'scopes': [
                  {
                    'realm_roles': [],
                    'client_roles': security.scopes.map { |scope| { 'name': scope } }
                  }
                ]
              },
              'enabled': true
            }
          end
        end
      end
    end
  end
end
