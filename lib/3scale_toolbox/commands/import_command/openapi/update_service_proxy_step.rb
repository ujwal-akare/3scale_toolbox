module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class UpdateServiceProxyStep
          include Step

          ##
          # Updates Proxy config
          def call
            # setting required attrs, operation is idempotent
            proxy_settings = {}

            add_api_backend_settings(proxy_settings)
            add_security_proxy_settings(proxy_settings)

            return unless proxy_settings.size.positive?

            res = service.update_proxy proxy_settings
            if (errors = res['errors'])
              raise ThreeScaleToolbox::Error, "Service proxy has not been updated. #{errors}"
            end

            puts 'Service proxy updated'
          end

          private

          def add_api_backend_settings(settings)
            return if api_spec.host.nil?

            scheme = api_spec.schemes.first || 'https'
            host = api_spec.host

            settings[:api_backend] = "#{scheme}://#{host}"
          end

          def add_security_proxy_settings(settings)
            # nothing to add on proxy settings when no security required in openapi
            return if security.nil?

            case security.type
            when 'oauth2'
              settings[:credentials_location] = 'headers'
              settings[:oidc_issuer_endpoint] = oidc_issuer_endpoint unless oidc_issuer_endpoint.nil?
            when 'apiKey'
              settings[:credentials_location] = credentials_location
              settings[:auth_user_key] = security.name
            else
              raise ThreeScaleToolbox::Error, "Unexpected security scheme type #{security.type}"
            end
          end

          def credentials_location
            case (in_f = security.in_f)
            when 'query'
              'query'
            when 'header'
              'headers'
            else
              raise ThreeScaleToolbox::Error, "Unexpected security in_f field #{in_f}"
            end
          end
        end
      end
    end
  end
end
