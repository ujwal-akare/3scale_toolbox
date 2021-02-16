module ThreeScaleToolbox
  module CRD
    class ProductParser
      Metric = Struct.new(:system_name, :friendly_name, :description, :unit)
      Method = Struct.new(:system_name, :friendly_name, :description)
      MappingRule = Struct.new(:metric_ref, :http_method, :pattern, :delta, :last)
      BackendUsage = Struct.new(:backend_system_name, :path)
      ApplicationPlan = Struct.new(:system_name, :name, :approval_required, :trial_period_days, :setup_fee, :custom, :state, :cost_per_month, :limits, :pricing_rules)
      Limit = Struct.new(:period, :value, :metric_system_name, :backend_system_name) do
        def to_s
          {period: period, value: value}.to_json
        end
      end
      PricingRule = Struct.new(:from, :to, :price_per_unit, :metric_system_name, :backend_system_name) do
        def to_s
          {from: from, to: to, price_per_unit: price_per_unit}.to_json
        end
      end
      PolicyChainItem = Struct.new(:name, :version, :configuration, :enabled)

      attr_reader :cr, :deployment_parser

      def initialize(cr)
        @cr = cr
        @deployment_parser = ProductDeploymentParser.new(cr.dig('spec', 'deployment') || {})
      end

      def system_name
        cr.dig('spec', 'systemName')
      end

      def name
        cr.dig('spec', 'name')
      end

      def description
        cr.dig('spec', 'description')
      end

      def metrics
        @metrics ||= (cr.dig('spec', 'metrics') || {}).map do |system_name, metric|
          Metric.new(system_name, metric['friendlyName'], metric['description'], metric['unit'])
        end
      end

      def methods
        @methods ||= (cr.dig('spec', 'methods') || {}).map do |system_name, method|
          Method.new(system_name, method['friendlyName'], method['description'])
        end
      end

      def mapping_rules
        @mapping_rules ||= (cr.dig('spec', 'mappingRules') || []).map do |mapping_rule|
          MappingRule.new(mapping_rule['metricMethodRef'], mapping_rule['httpMethod'],
            mapping_rule['pattern'], mapping_rule['increment'], mapping_rule['last'])
        end
      end

      # Metrics and methods index by system_name
      def metrics_index
        @metrics_index ||= (methods + metrics).each_with_object({}) { |metric, h| h[metric.system_name] = metric }
      end

      def application_plans
        @application_plans ||= (cr.dig('spec', 'applicationPlans') || {}).map do |system_name, plan|
          ApplicationPlan.new(system_name, plan['name'], plan['appsRequireApproval'],
                              plan['trialPeriod'], plan['setupFee'], plan['custom'], plan['state'],
                              plan['costMonth'], parse_limits(plan), parse_pricing_rules(plan))
        end
      end

      def backend_usages
        @backend_usages ||= (cr.dig('spec', 'backendUsages') || {}).map do |backend_system_name, usage|
          BackendUsage.new(backend_system_name, usage['path'])
        end
      end

      %i[deployment_option backend_version credentials_location auth_app_key
      auth_app_id auth_user_key error_auth_failed error_auth_missing error_status_auth_failed
      error_headers_auth_failed error_status_auth_missing error_headers_auth_missing error_no_match
      error_status_no_match error_headers_no_match error_limits_exceeded
      error_status_limits_exceeded error_headers_limits_exceeded secret_token hostname_rewrite
      endpoint sandbox_endpoint oidc_issuer_endpoint oidc_issuer_type jwt_claim_with_client_id
      jwt_claim_with_client_id_type standard_flow_enabled implicit_flow_enabled
      service_accounts_enabled direct_access_grants_enabled].each do |method_name|
        define_method method_name do
          deployment_parser.public_send(method_name)
        end
      end

      def policy_chain
        @policy_chain ||= (cr.dig('spec', 'policies') || []).map do |item|
          PolicyChainItem.new(item['name'], item['version'], item['configuration'], item['enabled'])
        end
      end

      private

      def parse_limits(plan)
        plan.fetch('limits', []).map do |limit|
          Limit.new(limit['period'], limit['value'],
                    limit.dig('metricMethodRef', 'systemName'), limit.dig('metricMethodRef', 'backend'))
        end
      end

      def parse_pricing_rules(plan)
        plan.fetch('pricingRules', []).map do |pr|
          PricingRule.new(pr['from'], pr['to'], pr['pricePerUnit'],
                    pr.dig('metricMethodRef', 'systemName'), pr.dig('metricMethodRef', 'backend'))
        end
      end
    end
  end
end
