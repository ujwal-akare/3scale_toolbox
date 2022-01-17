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

            reconcile_anonymous_access_policy(policies_settings)
            add_rh_sso_keycloak_role_check_policy(policies_settings)
            add_url_rewritting_policy(policies_settings)

            return if source_policies_settings == policies_settings

            res = service.update_policies('policies_config' => policies_settings)
            if res.is_a?(Hash) && (errors = res['errors'])
              raise ThreeScaleToolbox::Error, "Service policies have not been updated. #{errors}"
            end

            logger.info 'Service policies updated'
          end

          private

          def reconcile_anonymous_access_policy(policies)
            idx = policies.find_index { |p| p['name'] == 'default_credentials' }

            if api_spec.security.nil?
              # only on 'open api' security req
              # Update anonymous policy if exists
              #
              if idx.nil?
                # Anonymous policy should be before apicast policy
                # hence, adding as a first element
                policies.insert(0, anonymous_policy)
              else
                # only update if different
                if policies[idx].dig('configuration', 'user_key') != anonymous_policy.dig(:configuration, :user_key)
                  policies[idx] = anonymous_policy
                end
              end
            else
              unless idx.nil?
                policies.slice!(idx)
              end
            end
          end

          def anonymous_policy
            raise ThreeScaleToolbox::Error, 'User key must be provided by ' \
              '--default-credentials-userkey optional param' \
              if default_credentials_userkey.nil?

            {
              name: 'default_credentials',
              version: 'builtin',
              configuration: {
                auth_type: 'user_key',
                user_key: default_credentials_userkey
              },
              enabled: true
            }
          end

          def add_rh_sso_keycloak_role_check_policy(policies)
            # only applies to oauth2 sec type
            return if api_spec.security.nil? || api_spec.security[:type] != 'oauth2'

            return if policies.any? { |policy| policy['name'] == 'keycloak_role_check' }

            # only when there are scopes defined
            return if api_spec.security[:scopes].empty?

            policies << keycloak_policy
          end

          def keycloak_policy
            {
              name: 'keycloak_role_check',
              version: 'builtin',
              configuration: {
                type: 'whitelist',
                scopes: [
                  {
                    realm_roles: [],
                    client_roles: api_spec.security[:scopes].map { |scope| { 'name': scope } }
                  }
                ]
              },
              enabled: true
            }
          end

          def add_url_rewritting_policy(policies)
            return if private_base_path == public_base_path

            url_rewritting_policy_idx = policies.find_index do |policy|
              policy['name'] == 'url_rewriting'
            end

            if url_rewritting_policy_idx.nil?
              policies << url_rewritting_policy
            else
              policies[url_rewritting_policy_idx] = url_rewritting_policy
            end
          end

          def url_rewritting_policy
            regex = url_rewritting_policy_regex
            replace = url_rewritting_policy_replace
            # If regex has a / at the end, replace must have a / at the end
            replace.concat('/') if regex.end_with?('/') && !replace.end_with?('/')

            {
              name: 'url_rewriting',
              version: 'builtin',
              configuration: {
                commands: [
                  {
                    op: 'sub',
                    regex: regex,
                    replace: replace
                  }
                ]
              },
              enabled: true
            }
          end

          def url_rewritting_policy_regex
            "^#{public_base_path}"
          end

          def url_rewritting_policy_replace
            private_base_path
          end
        end
      end
    end
  end
end
