module ThreeScaleToolbox
  module Entities
    class ProxyConfig
      class << self
        def find(service:, environment:, version:)
          new(service: service, environment: environment, version: version).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end

        def find_latest(service:, environment:)
          proxy_cfg = service.remote.proxy_config_latest(service.id, environment)
          if (errors = proxy_cfg['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfig find_latest not read', errors)
          end
          new(service: service, environment: environment, version: proxy_cfg["version"], attrs: proxy_cfg)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end

        def from_cr(cr)
          deployment_parser = ProductDeploymentCRDParser.new(cr)
          {
            'endpoint' => deployment_parser.endpoint,
            'credentials_location' => deployment_parser.credentials_location,
            'auth_app_key' => deployment_parser.auth_app_key,
            'auth_app_id' => deployment_parser.auth_app_id,
            'auth_user_key' => deployment_parser.auth_user_key,
            'error_auth_failed' => deployment_parser.error_auth_failed,
            'error_auth_missing' => deployment_parser.error_auth_missing,
            'error_status_auth_failed' => deployment_parser.error_status_auth_failed,
            'error_headers_auth_failed' => deployment_parser.error_headers_auth_failed,
            'error_status_auth_missing' => deployment_parser.error_status_auth_missing,
            'error_headers_auth_missing' => deployment_parser.error_headers_auth_missing,
            'error_no_match' => deployment_parser.error_no_match,
            'error_status_no_match' => deployment_parser.error_status_no_match,
            'error_headers_no_match' => deployment_parser.error_headers_no_match,
            'error_limits_exceeded' => deployment_parser.error_limits_exceeded,
            'error_status_limits_exceeded' => deployment_parser.error_status_limits_exceeded,
            'error_headers_limits_exceeded' => deployment_parser.error_headers_limits_exceeded,
            'secret_token' => deployment_parser.secret_token,
            'hostname_rewrite' => deployment_parser.hostname_rewrite,
            'sandbox_endpoint' => deployment_parser.sandbox_endpoint,
            'oidc_issuer_endpoint' => deployment_parser.oidc_issuer_endpoint,
            'oidc_issuer_type' => deployment_parser.oidc_issuer_type,
            'jwt_claim_with_client_id' => deployment_parser.jwt_claim_with_client_id,
            'jwt_claim_with_client_id_type' => deployment_parser.jwt_claim_with_client_id_type
          }.delete_if { |k,v| v.nil? }
        end
      end

      attr_reader :remote, :service, :environment, :version

      def initialize(environment:, service:, version:, attrs: nil)
        @remote = service.remote
        @service = service
        @environment = environment
        @version = version
        @attrs = attrs
      end

      def attrs
        @attrs ||= proxy_config_attrs
      end

      def promote(to:)
        res = remote.promote_proxy_config(service.id, environment, version, to)

        if (errors = res['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfig not promoted', errors)
        end
        res
      end

      private

      def proxy_config_attrs
        proxy_cfg = remote.show_proxy_config(service.id, environment, version)

        if (errors = proxy_cfg['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfig not read', errors)
        end
        proxy_cfg
      end

    end
  end
end
