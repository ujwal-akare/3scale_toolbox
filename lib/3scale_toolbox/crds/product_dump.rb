module ThreeScaleToolbox
  module CRD
    module ProductSerializer
      def to_cr
        {
          'apiVersion' => 'capabilities.3scale.net/v1beta1',
          'kind' => 'Product',
          'metadata' => {
            'annotations' => {
              '3scale_toolbox_created_at' => Time.now.utc.iso8601,
              '3scale_toolbox_version' => ThreeScaleToolbox::VERSION
            },
            'name' => cr_name
          },
          'spec' => {
            'name' => name,
            'systemName' => system_name,
            'description' => description,
            'mappingRules' => mapping_rules.map(&:to_cr),
            'metrics' => metrics.each_with_object({}) do |metric, hash|
              hash[metric.system_name] = metric.to_cr
            end,
            'methods' => methods.each_with_object({}) do |method, hash|
              hash[method.system_name] = method.to_cr
            end,
            'policies' => policies,
            'applicationPlans' => plans.each_with_object({}) do |app_plan, hash|
              hash[app_plan.system_name] = app_plan.to_cr
            end,
            'backendUsages' => backend_usage_list.each_with_object({}) do |backend_usage, hash|
              hash[backend_usage.backend.system_name] = backend_usage.to_cr
            end,
            'deployment' => deployment_to_cr
          }
        }
      end

      def cr_name
        # Should be DNS1123 subdomain name
        # TODO run validation for DNS1123
        # https://kubernetes.io/docs/concepts/overview/working-with-objects/names/
        "#{system_name.gsub(/[^[a-zA-Z0-9\-\.]]/, '.')}.#{Helper.random_lowercase_name}"
      end

      def deployment_to_cr
        case deployment_option
        when 'hosted'
          hosted_deployment_to_cr
        when 'self_managed'
          self_managed_deployment_to_cr
        else
          raise ThreeScaleToolbox::Error, "Unknown deployment option: #{deployment_option}"
        end
      end

      def hosted_deployment_to_cr
        {
          'apicastHosted' => { 'authentication' => authentication_to_cr }
        }
      end

      def self_managed_deployment_to_cr
        {
          'apicastSelfManaged' => {
            'authentication' => authentication_to_cr,
            'stagingPublicBaseURL' => cached_proxy['sandbox_endpoint'],
            'productionPublicBaseURL' => cached_proxy['endpoint']
          }
        }
      end

      def authentication_to_cr
        case backend_version
        when '1'
          userkey_authentication_to_cr
        when '2'
          appkey_authentication_to_cr
        when 'oidc'
          oidc_authentication_to_cr
        else
          raise ThreeScaleToolbox::Error, "Unknown backend_version: #{backend_version}"
        end
      end

      def userkey_authentication_to_cr
        {
          'userkey' => {
            'authUserKey' => cached_proxy['auth_user_key'],
            'credentials' => cached_proxy['credentials_location'],
            'security' => security_to_cr,
            'gatewayResponse' => gateway_response_to_cr
          }
        }
      end

      def appkey_authentication_to_cr
        {
          'appKeyAppID' => {
            'appID' => cached_proxy['auth_app_id'],
            'appKey' => cached_proxy['auth_app_key'],
            'credentials' => cached_proxy['credentials_location'],
            'security' => security_to_cr,
            'gatewayResponse' => gateway_response_to_cr
          }
        }
      end

      def oidc_authentication_to_cr
        {
          'oidc' => {
            'issuerType' => cached_proxy['oidc_issuer_type'],
            'issuerEndpoint' => cached_proxy['oidc_issuer_endpoint'],
            'jwtClaimWithClientID' => cached_proxy['jwt_claim_with_client_id'],
            'jwtClaimWithClientIDType' => cached_proxy['jwt_claim_with_client_id_type'],
            'authenticationFlow' => oidc_flow_to_cr,
            'credentials' => cached_proxy['credentials_location'],
            'security' => security_to_cr,
            'gatewayResponse' => gateway_response_to_cr
          }
        }
      end

      def oidc_flow_to_cr
        {
          'standardFlowEnabled' => cached_oidc['standard_flow_enabled'],
          'implicitFlowEnabled' => cached_oidc['implicit_flow_enabled'],
          'serviceAccountsEnabled' => cached_oidc['service_accounts_enabled'],
          'directAccessGrantsEnabled' => cached_oidc['direct_access_grants_enabled']
        }
      end

      def security_to_cr
        {
          'hostHeader' => cached_proxy['hostname_rewrite'],
          'secretToken' => cached_proxy['secret_token']
        }
      end

      def gateway_response_to_cr
        {
          'errorStatusAuthFailed' => cached_proxy['error_status_auth_failed'],
          'errorHeadersAuthFailed' => cached_proxy['error_headers_auth_failed'],
          'errorAuthFailed' => cached_proxy['error_auth_failed'],
          'errorStatusAuthMissing' => cached_proxy['error_status_auth_missing'],
          'errorHeadersAuthMissing' => cached_proxy['error_headers_auth_missing'],
          'errorAuthMissing' => cached_proxy['error_auth_missing'],
          'errorStatusNoMatch' => cached_proxy['error_status_no_match'],
          'errorHeadersNoMatch' => cached_proxy['error_headers_no_match'],
          'errorNoMatch' => cached_proxy['error_no_match'],
          'errorStatusLimitsExceeded' => cached_proxy['error_status_limits_exceeded'],
          'errorHeadersLimitsExceeded' => cached_proxy['error_headers_limits_exceeded'],
          'errorLimitsExceeded' => cached_proxy['error_limits_exceeded']
        }
      end
    end
  end
end
