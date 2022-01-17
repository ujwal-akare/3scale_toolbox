module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class UpdateServiceProxyStep
          include Step

          ##
          # Updates Proxy config
          def call
            proxy_settings = {}

            add_endpoint_settings(proxy_settings)
            add_sandbox_endpoint_settings(proxy_settings)
            add_api_backend_settings(proxy_settings)
            add_security_proxy_settings(proxy_settings)

            return unless proxy_settings.size.positive?

            res = service.update_proxy proxy_settings
            if (errors = res['errors'])
              raise ThreeScaleToolbox::Error, "Service proxy has not been updated. #{errors}"
            end

            logger.info 'Service proxy updated'
          end

          private

          def add_endpoint_settings(settings)
            return if production_public_base_url.nil?

            settings[:endpoint] = production_public_base_url
            report['endpoint'] = production_public_base_url
          end

          def add_sandbox_endpoint_settings(settings)
            return if staging_public_base_url.nil?

            settings[:sandbox_endpoint] = staging_public_base_url
            report['sandbox_endpoint'] = staging_public_base_url
          end

          def add_api_backend_settings(settings)
            settings[:api_backend] = private_base_url unless private_base_url.nil?
            settings[:secret_token] = backend_api_secret_token unless backend_api_secret_token.nil?
            settings[:hostname_rewrite] = backend_api_host_header unless backend_api_host_header.nil?
          end

          def add_security_proxy_settings(settings)
            # nothing to add on proxy settings when no security required in openapi
            return if api_spec.security.nil?

            case (type = api_spec.security[:type])
            when 'oauth2'
              settings[:credentials_location] = 'headers'
              settings[:oidc_issuer_type] = oidc_issuer_type unless oidc_issuer_type.nil?
              settings[:oidc_issuer_endpoint] = oidc_issuer_endpoint unless oidc_issuer_endpoint.nil?
            when 'apiKey'
              settings[:credentials_location] = credentials_location
              settings[:auth_user_key] = api_spec.security[:name]
            else
              raise ThreeScaleToolbox::Error, "Unexpected security scheme type #{type}"
            end
          end

          def credentials_location
            case (in_f = api_spec.security[:in_f])
            when 'query'
              'query'
            when 'header'
              'headers'
            else
              raise ThreeScaleToolbox::Error, "Unexpected security in_f field #{in_f}"
            end
          end

          def private_base_url
            override_private_base_url || host
          end
        end
      end
    end
  end
end
