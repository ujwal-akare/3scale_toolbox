module ThreeScaleToolbox
  module Entities
    # ProductDeploymentCRDParser parses CRD Format
    # https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/doc/product-reference.md#productdeploymentspec
    class ProductDeploymentCRDParser
      class ApicastHostedParser
        attr_reader :authentication_parser

        def initialize(cr)
          @authentication_parser = AuthenticationParser.new(cr.fetch('authentication', {}))
        end

        def deployment_option
          'hosted'
        end

        def method_missing(name, *args)
          authentication_parser.public_send(name, *args)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end

      class ApicastSelfManagedParser
        attr_reader :authentication_parser, :cr

        def initialize(cr)
          @cr = cr
          @authentication_parser = AuthenticationParser.new(cr.fetch('authentication', {}))
        end

        def deployment_option
          'self_managed'
        end

        def endpoint
          cr['productionPublicBaseURL']
        end

        def sandbox_endpoint
          cr['stagingPublicBaseURL']
        end

        def method_missing(name, *args)
          authentication_parser.public_send(name, *args)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end

      class AuthenticationParser
        attr_reader :parser

        def initialize(cr)
          @parser = if cr.has_key? 'userkey'
                      UserKeyParser.new(cr.fetch('userkey'))
                    elsif cr.has_key? 'appKeyAppID'
                      AppKeyParser.new(cr.fetch('appKeyAppID'))
                    elsif cr.has_key? 'oidc'
                      OidcParser.new(cr.fetch('oidc'))
                    else
                      raise ThreeScaleToolbox::Error, "Unknown authentication option: #{cr.keys}"
                    end
        end


        def method_missing(name, *args)
          parser.public_send(name, *args)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end

      class AppKeyParser

        attr_reader :cr, :security_parser, :gaterway_response_parser

        def initialize(cr)
          @cr = cr
          @security_parser = SecurityParser.new(cr.fetch('security', {}))
          @gaterway_response_parser = GatewayResponseParser.new(cr.fetch('gatewayResponse', {}))
        end

        def auth_app_id
          cr['appID']
        end

        def auth_app_key
          cr['appKey']
        end

        def credentials_location
          cr['credentials']
        end

        def backend_version
          '2'
        end

        def method_missing(name, *args)
          res = security_parser.public_send(name, *args)
          return res unless res.nil?

          gaterway_response_parser.public_send(name, *args)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end

      class UserKeyParser
        attr_reader :cr, :security_parser, :gaterway_response_parser

        def initialize(cr)
          @cr = cr
          @security_parser = SecurityParser.new(cr.fetch('security', {}))
          @gaterway_response_parser = GatewayResponseParser.new(cr.fetch('gatewayResponse', {}))
        end

        def backend_version
          '1'
        end

        def auth_user_key
          cr['authUserKey']
        end

        def credentials_location
          cr['credentials']
        end

        def method_missing(name, *args)
          res = security_parser.public_send(name, *args)
          return res unless res.nil?

          gaterway_response_parser.public_send(name, *args)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end

      class OidcParser
        attr_reader :cr, :security_parser, :gaterway_response_parser

        def initialize(cr)
          @cr = cr
          @security_parser = SecurityParser.new(cr.fetch('security', {}))
          @gaterway_response_parser = GatewayResponseParser.new(cr.fetch('gatewayResponse', {}))
        end

        def backend_version
          'oidc'
        end

        def credentials_location
          cr['credentials']
        end

        def oidc_issuer_endpoint
          cr['issuerEndpoint']
        end

        def oidc_issuer_type
          cr['issuerType']
        end

        def jwt_claim_with_client_id
          cr['jwtClaimWithClientID']
        end

        def jwt_claim_with_client_id_type
          cr['jwtClaimWithClientIDType']
        end

        def method_missing(name, *args)
          res = security_parser.public_send(name, *args)
          return res unless res.nil?

          gaterway_response_parser.public_send(name, *args)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end

      class SecurityParser
        attr_reader :cr

        def initialize(cr)
          @cr = cr
        end

        def secret_token
          cr['secretToken']
        end

        def hostname_rewrite
          cr['hostHeader']
        end

        def method_missing(name, *args)
          nil
        end
      end

      class GatewayResponseParser
        attr_reader :cr

        def initialize(cr)
          @cr = cr
        end

        def error_auth_failed
          cr['errorAuthFailed']
        end

        def error_auth_missing
          cr['errorAuthMissing']
        end

        def error_status_auth_failed
          cr['errorStatusAuthFailed']
        end

        def error_headers_auth_failed
          cr['errorHeadersAuthFailed']
        end

        def error_status_auth_missing
          cr['errorStatusAuthMissing']
        end

        def error_headers_auth_missing
          cr['errorHeadersAuthMissing']
        end

        def error_no_match
          cr['errorNoMatch']
        end

        def error_status_no_match
          cr['errorStatusNoMatch']
        end

        def error_headers_no_match
          cr['errorHeadersNoMatch']
        end

        def error_limits_exceeded
          cr['errorLimitsExceeded']
        end

        def error_status_limits_exceeded
          cr['errorStatusLimitsExceeded']
        end

        def error_headers_limits_exceeded
          cr['errorHeadersLimitsExceeded']
        end

        def method_missing(name, *args)
          nil
        end
      end

      attr_reader :deployment_parser

      def initialize(cr)
        @deployment_parser = if cr.has_key? 'apicastSelfManaged'
                               ApicastSelfManagedParser.new(cr.fetch('apicastSelfManaged'))
                             elsif cr.has_key? 'apicastHosted'
                               ApicastHostedParser.new(cr.fetch('apicastHosted'))
                             else
                               raise ThreeScaleToolbox::Error, "Unknown deployment option: #{cr.keys}"
                             end
      end

      def method_missing(name, *args)
        deployment_parser.public_send(name, *args)
      end

      def respond_to_missing?(method_name, include_private = false)
        super
      end
    end
  end
end
