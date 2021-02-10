module ThreeScaleToolbox
  module Commands
    module ProductCommand
      module ImportCommand
        class CRDRemote

          attr_reader :id, :product, :backend_index
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
          #      applicationPlans:
          #        basic:
          #          name: Basic
          #          appsRequireApproval: false
          #          trialPeriod: 0
          #          setupFee: 0.0
          #          costMonth: 0.0
          #          pricingRules:
          #          - from: 1
          #            to: 1000
          #            pricePerUnit: 1.0
          #            metricMethodRef:
          #              systemName: hits
          #          limits:
          #          - period: eternity
          #            value: 10000
          #            metricMethodRef:
          #              systemName: hits
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
          def initialize(id, product, backends)
            @id = id
            @product = product
            # Index of backends referenced by the product in backend_usages
            @backend_index = build_backend_index(backends)

            validate!
          end

          def show_service(service_id)
            assert_service_id(service_id)

            Entities::Service.from_cr(id, product)
          end

          def list_backend_usages(service_id)
            assert_service_id(service_id)

            backend_index.map do |backend_id, backend|
              backend_usage = product_backend_usages.fetch(backend_system_name(backend))
              Entities::BackendUsage.from_cr(id, service_id, backend_id, backend_usage)
            end
          end

          def backend(backend_id)
            assert_backend_id(backend_id)

            Entities::Backend.from_cr(backend_id, backend_index.fetch(backend_id))
          end

          def list_backend_metrics(backend_id)
            assert_backend_id(backend_id)

            # return metrics and methods
            backend = backend_index.fetch(backend_id)
            serialized_backend_metrics(backend) + serialized_backend_methods(backend)
          end

          def list_backend_methods(backend_id, _)
            assert_backend_id(backend_id)

            backend = backend_index.fetch(backend_id)
            serialized_backend_methods(backend)
          end

          def list_backend_mapping_rules(backend_id)
            assert_backend_id(backend_id)

            backend = backend_index.fetch(backend_id)

            # Build metric index { system_name => metric_id }
            metric_index = backend_metric_method_index(backend).each_with_index.each_with_object({}) do |((system_name, _), idx), hash|
              hash[system_name] = idx + 1
            end

            backend_mapping_rules(backend).each_with_index.map do |mapping_rule, idx|
              # Previous validation assures mapping rule references are valid
              metric_id = metric_index.fetch(mapping_rule['metricMethodRef'])
              # 0 is not valid id
              Entities::BackendMappingRule.from_cr(idx + 1, metric_id, mapping_rule)
            end
          end

          def show_proxy
          end

          def http_client
            Struct.new(:endpoint).new('http://fromCR')
          end

          private

          def validate!
            validate_product_metric_method_uniqueness!

            validate_product_mapping_rule_references!

            validate_product_application_plan_limit_references!

            validate_product_application_plan_pricingrule_references!

            validate_backend_metric_method_uniqueness!

            validate_backend_mapping_rule_references!
          end

          def product_backend_usages
            product.dig('spec', 'backendUsages') || {}
          end

          def product_mapping_rules
            product.dig('spec', 'mappingRules') || []
          end

          def product_system_name
            product.dig('spec', 'systemName')
          end

          def product_metrics
            product.dig('spec', 'metrics') || {}
          end

          def product_methods
            product.dig('spec', 'methods') || {}
          end

          def backend_system_name(backend)
            backend.dig('spec', 'systemName')
          end

          def backend_metrics(backend)
            backend.dig('spec', 'metrics') || {}
          end

          def backend_methods(backend)
            backend.dig('spec', 'methods') || {}
          end

          def backend_mapping_rules(backend)
            backend.dig('spec', 'mappingRules') || []
          end

          def backend_metric_method_index(backend)
            backend_metrics(backend).merge(backend_methods(backend))
          end

          def serialized_backend_metrics(backend)
            # iterating from the metric and method index,
            # metric_id will be unique for all metrics and methods
            metrics = backend_metric_method_index(backend).each_with_index.select do |(system_name, m), idx|
              backend_metrics(backend).has_key? system_name
            end

            metrics.map do |(system_name, m), idx|
              # 0 is not valid id
              Entities::BackendMetric.from_cr(idx + 1, system_name, m)
            end
          end

          def serialized_backend_methods(backend)
            # iterating from the metric and method index,
            # method_id will be unique for all metrics and methods
            methods = backend_metric_method_index(backend).each_with_index.select do |(system_name, _), _|
              backend_methods(backend).has_key? system_name
            end

            methods.map do |(system_name, m), idx|
              # 0 is not valid id
              Entities::BackendMethod.from_cr(idx + 1, system_name, m)
            end
          end

          def validate_product_mapping_rule_references!
            product_mapping_rules.each do |mapping_rule|
              product_metric_method_index.fetch(mapping_rule['metricMethodRef']) do
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product_system_name} " \
                  "Mapping rule {#{mapping_rule['httpMethod']} #{mapping_rule['pattern']}} " \
                  "referencing to metric #{mapping_rule['metricMethodRef']} has not been found"
              end
            end
          end

          def validate_product_metric_method_uniqueness!
            if product_metric_method_index.length != product_metrics.length + product_methods.length
              raise ThreeScaleToolbox::Error, "Invalid content. Metrics and method system names are not unique"
            end
          end

          def validate_product_application_plan_limit_references!
          end

          def validate_product_application_plan_pricingrule_references!
          end

          def validate_backend_metric_method_uniqueness!
            backend_index.each_value do |backend|
              if backend_metric_method_index(backend).length != backend_metrics(backend).length + backend_methods(backend).length
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                "Backend #{backend_system_name(backend)} metrics and method system names are not unique"
              end
            end
          end

          def validate_backend_mapping_rule_references!
            backend_index.each_value do |backend|
              backend_mapping_rules(backend).each do |mapping_rule|
                backend_metric_method_index(backend).fetch(mapping_rule['metricMethodRef']) do
                  raise ThreeScaleToolbox::Error, "Invalid content. " \
                    "Backend {#{backend_system_name(backend)} " \
                    "Mapping rule {#{mapping_rule['httpMethod']} #{mapping_rule['pattern']}} " \
                    "referencing to metric #{mapping_rule['metricMethodRef']} has not been found"
                end
              end
            end
          end

          def assert_backend_id(backend_id)
            backend_index.fetch(backend_id) do
              raise ThreeScaleToolbox::Error, "Unexpected event in CRDRemote class. " \
                "Received Backend #{backend_id} not found"
            end
          end

          def assert_service_id(service_id)
            if service_id != id
              raise ThreeScaleToolbox::Error, "Unexpected event in CRDRemote class. " \
                "Expected Service #{id}, received #{service_id}"
            end
          end

          # Build backend index, indexed by backend_id
          # only backends in backend usage will be included
          def build_backend_index(backends)
            backend_by_system_name = backends.each_with_object({}) do |b, hash|
              hash[b.dig('spec', 'systemName')] = b
            end

            product_backend_usages.each_with_index.each_with_object({}) do |((system_name, usage), idx), hash|
              # backend_id will be backend_usage_idx + 1 (0 is not valid id)
              hash[idx + 1] = backend_by_system_name.fetch(system_name) do
                # validate backend usage references are correct
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Product {#{product_system_name}" \
                  "backend usage reference to backend #{system_name} has not been found"
              end
            end
          end

          def product_metric_method_index
            @product_metric_method_index ||= product_metrics.merge(product_methods)
          end
        end
      end
    end
  end
end
