module ThreeScaleToolbox
  module CRD
    class Remote

      #
      # Product CRD Format
      # https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/doc/product-reference.md
      #
      #     apiVersion: capabilities.3scale.net/v1beta1
      #     kind: Product
      #     metadata:
      #       annotations:
      #         3scale_toolbox_created_at: '2021-02-10T09:16:59Z'
      #         3scale_toolbox_version: 0.17.1
      #       name: api.vygczmih
      #     spec:
      #       name: Default API
      #       systemName: api
      #       description: ''
      #       mappingRules:
      #       - httpMethod: GET
      #         pattern: "/v1"
      #         metricMethodRef: servicemethod01
      #         increment: 1
      #         last: false
      #       metrics:
      #         hits:
      #           friendlyName: Hits
      #           unit: hit
      #           description: Number of API hits
      #       methods:
      #         servicemethod01:
      #           friendlyName: servicemethod01
      #           description: ''
      #       policies:
      #       - name: apicast
      #         version: builtin
      #         configuration: {}
      #         enabled: true
      #       backendUsages:
      #         backend_01:
      #           path: "/v1/pets"
      #         backend_02:
      #           path: "/v1/cats"
      #       deployment:
      #         apicastSelfManaged:
      #           authentication:
      #             appKeyAppID:
      #               appID: app_id
      #               appKey: app_key
      #               credentials: query
      #               security:
      #                 hostHeader: ''
      #                 secretToken: some_secret
      #               gatewayResponse:
      #                 errorStatusAuthFailed: 403
      #                 errorHeadersAuthFailed: text/plain; charset=us-ascii
      #                 errorAuthFailed: Authentication failed
      #                 errorStatusAuthMissing: 403
      #                 errorHeadersAuthMissing: text/plain; charset=us-ascii
      #                 errorAuthMissing: Authentication parameters missing
      #                 errorStatusNoMatch: 404
      #                 errorHeadersNoMatch: text/plain; charset=us-ascii
      #                 errorNoMatch: No Mapping Rule matched
      #                 errorStatusLimitsExceeded: 429
      #                 errorHeadersLimitsExceeded: text/plain; charset=us-ascii
      #                 errorLimitsExceeded: Usage limit exceeded
      #           stagingPublicBaseURL: http://staging.example.com:80
      #           productionPublicBaseURL: http://example.com:80
      #       applicationPlans:
      #         basic:
      #           name: Basic
      #           appsRequireApproval: false
      #           trialPeriod: 0
      #           setupFee: 0.0
      #           custom: false
      #           state: published
      #           costMonth: 0.0
      #           pricingRules:
      #           - from: 1
      #             to: 1000
      #             pricePerUnit: 1.0
      #             metricMethodRef:
      #               systemName: hits
      #           limits:
      #           - period: eternity
      #             value: 10000
      #             metricMethodRef:
      #               systemName: hits
      #
      # Backend CRD format
      # https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/doc/backend-reference.md
      #
      #     apiVersion: capabilities.3scale.net/v1beta1
      #     kind: Backend
      #     metadata:
      #       annotations:
      #         3scale_toolbox_created_at: '2021-02-10T09:17:12Z'
      #         3scale_toolbox_version: 0.17.1
      #       name: backend.01.rxoeasvk
      #     spec:
      #       name: Backend 01
      #       systemName: backend_01
      #       privateBaseURL: https://echo-api.3scale.net:443
      #       description: new desc
      #       mappingRules:
      #       - httpMethod: GET
      #         pattern: "/v1/pets"
      #         metricMethodRef: mybackendmethod01
      #         increment: 1
      #         last: false
      #       metrics:
      #         hits:
      #           friendlyName: Hits
      #           unit: hit
      #           description: Number of API hits
      #       methods:
      #         mybackendmethod01:
      #           friendlyName: mybackendmethod01
      #           description: ''

      attr_reader :product_index, :backend_index

      def initialize(products, backends)
        # Index of backends by id (by sequence order)
        @backend_index = backends.each_with_object({}) { |backend, hash| hash[new_index] = backend }

        # Index of products by id (by sequence order)
        @product_index = products.each_with_object({}) { |product, hash| hash[new_index] = product }

        validate!
      end

      def http_client
        Struct.new(:endpoint).new('http://fromCR')
      end

      def show_service(service_id)
        service = product_index.fetch(service_id) { raise_product_missing(service_id) }
        {
          'id' => service_id,
          'name' => service.name,
          'system_name' => service.system_name,
          'description' => service.description,
          'deployment_option' => service.deployment_option,
          'backend_version' => service.backend_version
        }
      end

      def list_services(page:, per_page:)
        product_index.keys.map(&method(:show_service))
      end

      def backend(backend_id)
        b = backend_index.fetch(backend_id) { raise_backend_missing(backend_id) }
        {
          'id' => backend_id,
          'name' => b.name,
          'system_name' => b.system_name,
          'description' => b.description,
          'private_endpoint' => b.private_endpoint
        }
      end

      def list_backend_usages(service_id)
        service = product_index.fetch(service_id) { raise_product_missing(service_id) }
        service.backend_usages.each_with_index.map do |backend_usage, idx|
          {
            'id' => idx + 1,
            'path' => backend_usage.path,
            'service_id' => service_id,
            'backend_id' => backend_index.find { |k, b| b.system_name == backend_usage.backend_system_name }.first
          }
        end
      end

      # return metrics and methods
      def list_backend_metrics(backend_id)
        metric_index = backend_metric_index.fetch(backend_id) { raise_backend_missing(backend_id) }

        # only metrics, not methods
        backend_metric_system_name_list = backend_index.fetch(backend_id).metrics.map(&:system_name)

        # select only metrics
        backend_metric_only_index = metric_index.select do |_, metric|
          backend_metric_system_name_list.include? metric.system_name
        end

        backend_metric_only_index.map do |metric_id, metric|
          {
            'id' => metric_id,
            'friendly_name' => metric.friendly_name,
            'system_name' => metric.system_name,
            'description' => metric.description,
            'unit' => metric.unit
          }
        end + list_backend_methods(backend_id, 0)
      end

      def list_backend_methods(backend_id, _)
        metric_index = backend_metric_index.fetch(backend_id) { raise_backend_missing(backend_id) }

        backend_method_system_name_list = backend_index.fetch(backend_id).methods.map(&:system_name)

        # select only methods
        backend_method_index = metric_index.select do |_, metric|
          backend_method_system_name_list.include? metric.system_name
        end

        backend_method_index.map do |method_id, method|
          {
            'id' => method_id,
            'parent_id' => 1, # should not be used
            'friendly_name' => method.friendly_name,
            'system_name' => method.system_name,
            'description' => method.description
          }
        end
      end

      def list_backend_mapping_rules(backend_id)
        metric_index = backend_metric_index.fetch(backend_id) { raise_backend_missing(backend_id) }

        backend_index.fetch(backend_id).mapping_rules.each_with_index.map do |mapping_rule, mapping_id|
          {
            # 0 is not valid id
            'id' => mapping_id + 1,
            'pattern' => mapping_rule.pattern,
            'http_method' => mapping_rule.http_method,
            'delta' => mapping_rule.delta,
            'last' => mapping_rule.last,
            # Previous validation assures mapping rule metric references are valid
            'metric_id' => metric_index.find { |_, metric| metric.system_name == mapping_rule.metric_ref }.first
          }
        end
      end

      def show_proxy(service_id)
        service = product_index.fetch(service_id) { raise_product_missing(service_id) }
        {
          'endpoint' => service.endpoint,
          'credentials_location' => service.credentials_location,
          'auth_app_key' => service.auth_app_key,
          'auth_app_id' => service.auth_app_id,
          'auth_user_key' => service.auth_user_key,
          'error_auth_failed' => service.error_auth_failed,
          'error_auth_missing' => service.error_auth_missing,
          'error_status_auth_failed' => service.error_status_auth_failed,
          'error_headers_auth_failed' => service.error_headers_auth_failed,
          'error_status_auth_missing' => service.error_status_auth_missing,
          'error_headers_auth_missing' => service.error_headers_auth_missing,
          'error_no_match' => service.error_no_match,
          'error_status_no_match' => service.error_status_no_match,
          'error_headers_no_match' => service.error_headers_no_match,
          'error_limits_exceeded' => service.error_limits_exceeded,
          'error_status_limits_exceeded' => service.error_status_limits_exceeded,
          'error_headers_limits_exceeded' => service.error_headers_limits_exceeded,
          'secret_token' => service.secret_token,
          'hostname_rewrite' => service.hostname_rewrite,
          'sandbox_endpoint' => service.sandbox_endpoint,
          'oidc_issuer_endpoint' => service.oidc_issuer_endpoint,
          'oidc_issuer_type' => service.oidc_issuer_type,
          'jwt_claim_with_client_id' => service.jwt_claim_with_client_id,
          'jwt_claim_with_client_id_type' => service.jwt_claim_with_client_id_type
        }.delete_if { |k,v| v.nil? }
      end

      def show_oidc(service_id)
        service = product_index.fetch(service_id) { raise_product_missing(service_id) }
        {
          'id' => service_id, #should not be used
          'standard_flow_enabled' => service.standard_flow_enabled,
          'implicit_flow_enabled' => service.implicit_flow_enabled,
          'service_accounts_enabled' => service.service_accounts_enabled,
          'direct_access_grants_enabled' => service.direct_access_grants_enabled
        }
      end

      def list_metrics(service_id)
        metric_index = product_metric_index.fetch(service_id) { raise_product_missing(service_id) }

        # only metrics, not methods
        product_metric_system_name_list = product_index.fetch(service_id).metrics.map(&:system_name)

        # select only metrics
        product_metric_only_index = metric_index.select do |_, metric|
          product_metric_system_name_list.include? metric.system_name
        end

        product_metric_only_index.map do |metric_id, metric|
          {
            'id' => metric_id,
            'friendly_name' => metric.friendly_name,
            'system_name' => metric.system_name,
            'description' => metric.description,
            'unit' => metric.unit
          }
        end + list_methods(service_id, 0)
      end

      def list_methods(service_id, _)
        metric_index = product_metric_index.fetch(service_id) { raise_product_missing(service_id) }

        product_method_system_name_list = product_index.fetch(service_id).methods.map(&:system_name)

        # select only methods
        product_method_index = metric_index.select do |_, metric|
          product_method_system_name_list.include? metric.system_name
        end

        product_method_index.map do |method_id, method|
          {
            'id' => method_id,
            'parent_id' => 1, # should not be used
            'friendly_name' => method.friendly_name,
            'system_name' => method.system_name,
            'description' => method.description
          }
        end
      end

      def list_mapping_rules(service_id)
        metric_index = product_metric_index.fetch(service_id) { raise_product_missing(service_id) }

        product_index.fetch(service_id).mapping_rules.each_with_index.map do |mapping_rule, mapping_id|
          {
            # 0 is not valid id
            'id' => mapping_id + 1,
            'pattern' => mapping_rule.pattern,
            'http_method' => mapping_rule.http_method,
            'delta' => mapping_rule.delta,
            'last' => mapping_rule.last,
            # Previous validation assures mapping rule metric references are valid
            'metric_id' => metric_index.find { |_, metric| metric.system_name == mapping_rule.metric_ref }.first
          }
        end
      end

      def list_service_application_plans(service_id)
        plan_index = product_plan_index.fetch(service_id) { raise_product_missing(service_id) }

        plan_index.map do |plan_id, plan|
          {
            'id' => plan_id,
            'name' => plan.name,
            'setup_fee' => plan.setup_fee,
            'custom' => plan.custom,
            'state' => plan.state,
            'cost_per_month' => plan.cost_per_month,
            'trial_period_days' => plan.trial_period_days,
            'approval_required' => plan.approval_required,
            'system_name' => plan.system_name
          }
        end
      end

      def list_application_plan_limits(plan_id)
        plan = application_plan_index.fetch(plan_id) { raise_plan_missing(plan_id) }
        plan.limits.map do |limit|
          {
            'id' => 1, # should not be used
            'period' => limit.period,
            'value' => limit.value,
            'metric_id' => find_metric_id_from_ref(plan_id, limit.metric_system_name, limit.backend_system_name),
            'plan_id' => plan_id
          }
        end
      end

      def show_policies(service_id)
        service = product_index.fetch(service_id) { raise_product_missing(service_id) }
        service.policy_chain.map do |policy_chain_item|
          {
            'name' => policy_chain_item.name,
            'version' => policy_chain_item.version,
            'configuration' => policy_chain_item.configuration,
            'enabled' => policy_chain_item.enabled
          }
        end
      end

      def list_pricingrules_per_application_plan(plan_id)
        plan = application_plan_index.fetch(plan_id) { raise_plan_missing(plan_id) }
        plan.pricing_rules.map do |pr|
          {
            'id' => 1, # should not be used
            'cost_per_unit' => pr.price_per_unit,
            'min' => pr.from,
            'max' => pr.to,
            'metric_id' => find_metric_id_from_ref(plan_id, pr.metric_system_name, pr.backend_system_name),
            'plan_id' => plan_id
          }
        end
      end

      def list_activedocs
        []
      end

      def delete_service(id)
        true
      end

      def delete_backend(id)
        true
      end

      def delete_backend_usage(product_id, id)
        true
      end

      private

      def validate!
        validate_product_metric_method_uniqueness!

        validate_product_mapping_rule_references!

        validate_product_backend_usage_references!

        validate_product_application_plan_limit_backend_references!

        validate_product_application_plan_limit_backend_metric_references!

        validate_product_application_plan_limit_metric_references!

        validate_product_application_plan_pricingrule_backend_references!

        validate_product_application_plan_pricingrule_backend_metric_references!

        validate_product_application_plan_pricingrule_metric_references!

        validate_backend_metric_method_uniqueness!

        validate_backend_mapping_rule_references!
      end

      def validate_product_metric_method_uniqueness!
        product_index.each_value do |product|
          system_name_list = product.metrics.map(&:system_name) + product.methods.map(&:system_name)
          if system_name_list.length != system_name_list.uniq.length
            raise ThreeScaleToolbox::Error, "Invalid content. " \
              "Product #{product.system_name} contains metrics and method system names that are not unique"
          end
        end
      end

      def validate_product_mapping_rule_references!
        product_index.each_value do |product|
          product.mapping_rules.each do |mapping_rule|
            product.metrics_index.fetch(mapping_rule.metric_ref) do
              raise ThreeScaleToolbox::Error, "Invalid content. " \
                "Product {#{product.system_name} " \
                "Mapping rule {#{mapping_rule.http_method} #{mapping_rule.pattern}} " \
                "referencing to metric #{mapping_rule.metric_ref} has not been found"
            end
          end
        end
      end

      def validate_product_backend_usage_references!
        product_index.each_value do |product|
          product.backend_usages.each do |backend_usage|
            if backend_index.values.none? { |backend| backend.system_name == backend_usage.backend_system_name }
              raise ThreeScaleToolbox::Error, "Invalid content. Product {#{product.system_name}" \
                "backend usage reference to backend #{backend_usage.backend_system_name} has not been found"
            end
          end
        end
      end

      # validate limit backend references
      def validate_product_application_plan_limit_backend_references!
        product_index.each_value do |product|
          product.application_plans.each do |plan|
            limits_with_backend_ref = plan.limits.reject { |limit| limit.backend_system_name.nil? }
            limits_with_backend_ref.each do |limit|
              unless product.backend_usages.map(&:backend_system_name).include? limit.backend_system_name
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product.system_name} " \
                  "Limit {#{limit.to_s}}, the backend #{limit.backend_system_name} " \
                  "has not been found in backend usages"
              end
            end
          end
        end
      end

      # validate limit metric with backend references
      def validate_product_application_plan_limit_backend_metric_references!
        product_index.each_value do |product|
          product.application_plans.each do |plan|
            limits_with_backend_ref = plan.limits.reject { |limit| limit.backend_system_name.nil? }
            limits_with_backend_ref.each do |limit|
              # It is already validated that backend references are correct, hence it must exist
              limit_backend_ref = backend_index.values.find { |b| b.system_name == limit.backend_system_name }
              unless (limit_backend_ref.methods + limit_backend_ref.metrics).map(&:system_name).include? limit.metric_system_name
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product.system_name} " \
                  "Limit {#{limit.to_s}}, the metric #{limit.metric_system_name} " \
                  "has not been found in backend #{limit_backend_ref.system_name}"
              end
            end
          end
        end
      end

      # validate limit metric references in product metrics and methods
      def validate_product_application_plan_limit_metric_references!
        product_index.each_value do |product|
          product.application_plans.each do |plan|
            limits_with_product_ref = plan.limits.select { |limit| limit.backend_system_name.nil? }
            limits_with_product_ref.each do |limit|
              unless (product.methods + product.metrics).map(&:system_name).include? limit.metric_system_name
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product.system_name} " \
                  "Limit {#{limit.to_s}}, the metric #{limit.metric_system_name} " \
                  "has not been found"
              end
            end
          end
        end
      end

      # validate pricing rules backend references
      def validate_product_application_plan_pricingrule_backend_references!
        product_index.each_value do |product|
          product.application_plans.each do |plan|
            pr_list_with_backend_ref = plan.pricing_rules.reject { |pr| pr.backend_system_name.nil? }
            pr_list_with_backend_ref.each do |pr|
              unless product.backend_usages.map(&:backend_system_name).include? pr.backend_system_name
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product.system_name} " \
                  "PricingRule {#{pr.to_s}}, the backend #{pr.backend_system_name} " \
                  "has not been found in backend usages"
              end
            end
          end
        end
      end

      # validate pricing rule metric with backend references
      def validate_product_application_plan_pricingrule_backend_metric_references!
        product_index.each_value do |product|
          product.application_plans.each do |plan|
            pr_list_with_backend_ref = plan.pricing_rules.reject { |pr| pr.backend_system_name.nil? }
            pr_list_with_backend_ref.each do |pr|
              # It is already validated that backend references are correct, hence it must exist
              pr_backend_ref = backend_index.values.find { |b| b.system_name == pr.backend_system_name }
              unless (pr_backend_ref.methods + pr_backend_ref.metrics).map(&:system_name).include? pr.metric_system_name
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product.system_name} " \
                  "PricingRule {#{pr.to_s}}, the metric #{pr.metric_system_name} " \
                  "has not been found in backend #{pr_backend_ref.system_name}"
              end
            end
          end
        end
      end

      # validate pricing rule metric references in product metrics and methods
      def validate_product_application_plan_pricingrule_metric_references!
        product_index.each_value do |product|
          product.application_plans.each do |plan|
            pr_list_with_product_ref = plan.pricing_rules.select { |pr| pr.backend_system_name.nil? }
            pr_list_with_product_ref.each do |pr|
              unless (product.methods + product.metrics).map(&:system_name).include? pr.metric_system_name
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product.system_name} " \
                  "PricingRule {#{pr.to_s}}, the metric #{pr.metric_system_name} " \
                  "has not been found"
              end
            end
          end
        end
      end

      def validate_backend_metric_method_uniqueness!
        backend_index.each_value do |backend|
          system_name_list = backend.metrics.map(&:system_name) + backend.methods.map(&:system_name)
          if system_name_list.length != system_name_list.uniq.length
            raise ThreeScaleToolbox::Error, "Invalid content. " \
              "Backend #{backend.system_name} contains metrics and method system names that are not unique"
          end
        end
      end

      def validate_backend_mapping_rule_references!
        backend_index.each_value do |backend|
          backend.mapping_rules.each do |mapping_rule|
            backend.metrics_index.fetch(mapping_rule.metric_ref) do
              raise ThreeScaleToolbox::Error, "Invalid content. " \
                "Backend {#{backend.system_name} " \
                "Mapping rule {#{mapping_rule.http_method} #{mapping_rule.pattern}} " \
                "referencing to metric #{mapping_rule.metric_ref} has not been found"
            end
          end
        end
      end


      # Index: backend_id -> metric_id -> metric or method
      # metric and methods have unique indexes
      def backend_metric_index
        @backend_metric_index ||= backend_index.each_with_object({}) do |(backend_id, backend), backend_index|
          metric_method_list = backend.metrics + backend.methods
          backend_index[backend_id] = metric_method_list.each_with_object({}) do |metric, metric_index|
            metric_index[new_index] = metric
          end
        end
      end

      # Index: plan_id -> plan
      def application_plan_index
        product_plan_index.values.inject({}) { |acc, plan_index| acc.merge(plan_index) }
      end

      # Index: product_id -> plan_id -> plan
      def product_plan_index
        @product_plan_index ||= product_index.each_with_object({}) do |(product_id, product), product_index|
          product_index[product_id] = product.application_plans.each_with_object({}) do |plan, plan_index|
            plan_index[new_index] = plan
          end
        end
      end

      # Index: plan_id -> product_id
      def plan_product_index
        @plan_product_index ||= product_plan_index.each_with_object({}) do |(product_id, plan_index), hash|
          plan_index.keys.each { |plan_id| hash[plan_id] = product_id }
        end
      end

      # Index: product_id -> metric_id -> metric
      def product_metric_index
        @product_metric_index ||= product_index.each_with_object({}) do |(product_id, product), product_index|
          metric_method_list = product.metrics + product.methods
          product_index[product_id] = metric_method_list.each_with_object({}) do |metric, metric_index|
            metric_index[new_index] = metric
          end
        end
      end

      def new_index
        # starts on 1
        @new_index ||= 0
        @new_index += 1
      end

      def find_metric_id_from_ref(plan_id, system_name, backend_system_name)
        if backend_system_name.nil?
          product_id = plan_product_index.fetch(plan_id)
          product_metric_index.fetch(product_id).find do |_, metric|
            metric.system_name == system_name
          end.first
        else
          # it is validated that backend is in application backend usages
          # so it can be safely search in the whole backend index, and must exist
          backend_id = backend_index.find { |_, b| b.system_name == backend_system_name }.first
          backend_metric_index.fetch(backend_id).find do |_, metric|
            metric.system_name == system_name
          end.first
        end
      end

      def raise_backend_missing(backend_id)
        raise ThreeScaleToolbox::Error, "Unexpected event in CRDRemote class. " \
          "Backend #{backend_id} not found in the index"
      end

      def raise_product_missing(product_id)
          raise ThreeScaleToolbox::Error, "Unexpected event in CRDRemote class. " \
            "Service #{product_id} not found in the index"
      end

      def raise_plan_missing(plan_id)
          raise ThreeScaleToolbox::Error, "Unexpected event in CRDRemote class. " \
            "ApplicationPlan #{plan_id} not found in the index"
      end
    end
  end
end
