module ThreeScaleToolbox
  module Entities
    class Backend
      VALID_PARAMS = %w[name description system_name private_endpoint].freeze
      public_constant :VALID_PARAMS

      class << self
        def create(remote:, attrs:)
          b_attrs = remote.create_backend Helper.filter_params(VALID_PARAMS, attrs)
          if (errors = b_attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend has not been created', errors)
          end

          new(id: b_attrs.fetch('id'), remote: remote, attrs: b_attrs)
        end

        # ref can be system_name or backend_id
        def find(remote:, ref:)
          new(id: ref, remote: remote).tap(&:attrs)
        rescue ThreeScaleToolbox::InvalidIdError, ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(remote: remote, system_name: ref)
        end

        def find_by_system_name(remote:, system_name:)
          attrs = list_backends(remote: remote).find do |backend|
            backend['system_name'] == system_name
          end
          return if attrs.nil?

          new(id: attrs.fetch('id'), remote: remote, attrs: attrs)
        end

        def from_cr(remote:, cr:)
          context = {
            source_backend: build_backend_from(cr),
            target_remote: remote
          }

          tasks = []
          tasks << Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask.new(context)
          # First metrics as methods need 'hits' metric in target backend
          tasks << Commands::BackendCommand::CopyCommand::CopyMetricsTask.new(context)
          tasks << Commands::BackendCommand::CopyCommand::CopyMethodsTask.new(context)
          tasks << Commands::BackendCommand::CopyCommand::CopyMappingRulesTask.new(context)
          tasks.each(&:call)
        end

        private

        def list_backends(remote:)
          backends_enum(remote: remote).reduce([], :concat)
        end

        def backends_enum(remote:)
          Enumerator.new do |yielder|
            page = 1
            loop do
              list = remote.list_backends(
                page: page,
                per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE
              )

              if list.respond_to?(:has_key?) && (errors = list['errors'])
                raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend list not read', errors)
              end

              break if list.nil?

              yielder << list

              # The API response does not tell how many pages there are available
              # If one page is not fully filled, it means that it is the last page.
              break if list.length < ThreeScale::API::MAX_BACKENDS_PER_PAGE

              page += 1
            end
          end
        end

        def build_backend_from(cr)
          backend_remote = BackendRemote.new(
            methods: methods_from_cr(cr),
            metrics: metrics_from_cr(cr),
            mapping_rules: mapping_rules_from_cr(cr),
            attrs: attrs_from_cr(cr)
          )
          new(id: 1, remote: backend_remote, attrs: attrs_from_cr(cr))
        end

        def methods_from_cr(cr)
          # method index can not conflict with metric index. Index is unique among metrics and methods
          base_idx = metrics_from_cr(cr).length
          (cr.dig('spec', 'methods') || {}).each_with_index.map do |(system_name, attrs), idx|
            {
              'id' => base_idx + idx,
              'name' => attrs['friendlyName'],
              'friendly_name' => attrs['friendlyName'],
              'system_name' => system_name,
              'description' => attrs['description'],
            }
          end
        end

        def metrics_from_cr(cr)
          (cr.dig('spec', 'metrics') || {}).each_with_index.map do |(system_name, attrs), idx|
            {
              'id' => idx,
              'name' => attrs['friendlyName'],
              'friendly_name' => attrs['friendlyName'],
              'system_name' => system_name,
              'description' => attrs['description'],
              'unit' => attrs['unit']
            }
          end
        end

        def mapping_rules_from_cr(cr)
          (cr.dig('spec', 'mappingRules') || []).each_with_index.map do |attrs, idx|
            {
              'id' => idx,
              'pattern' => attrs['pattern'],
              'http_method' => attrs['httpMethod'],
              'delta' => attrs['increment'],
              'last' => attrs['last'],
              'metric_id' => methods_metrics_id_by_system_name(cr).fetch(attrs['metricMethodRef']) do
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Mapping rule {#{attrs['httpMethod']} #{attrs['httpMethod']}} " \
                  "referencing to metric #{attrs['metricMethodRef']} has not been found"
              end
            }
          end
        end

        def methods_metrics_id_by_system_name(cr)
            (metrics_from_cr(cr) + methods_from_cr(cr)).each_with_object({}) do |m, hash|
              hash[m['system_name']] = m['id']
            end
        end

        def attrs_from_cr(cr)
          {
            'id' => 1, # should not be used
            'name' => cr.dig('spec', 'name'),
            'system_name' => cr.dig('spec', 'systemName'),
            'description' => cr.dig('spec', 'description'),
            'private_endpoint' => cr.dig('spec', 'privateBaseURL')
          }
        end
      end

      attr_reader :id, :remote

      def initialize(id:, remote:, attrs: nil)
        @id = id.to_i
        @remote = remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= fetch_backend_attrs
      end

      def system_name
        attrs['system_name']
      end

      def description
        attrs['description']
      end

      def name
        attrs['name']
      end

      def private_endpoint
        attrs['private_endpoint']
      end

      def metrics
        metric_attr_list = ThreeScaleToolbox::Helper.array_difference(metrics_and_methods, methods) do |item, method|
          method.id == item.fetch('id', nil)
        end

        metric_attr_list.map do |metric_attrs|
          BackendMetric.new(id: metric_attrs.fetch('id'), backend: self, attrs: metric_attrs)
        end
      end

      def hits
        metric_list = metrics_and_methods.map do |metric_attrs|
          BackendMetric.new(id: metric_attrs.fetch('id'), backend: self, attrs: metric_attrs)
        end
        metric_list.find { |metric| metric.system_name == 'hits' }.tap do |hits_metric|
          raise ThreeScaleToolbox::Error, 'missing hits metric' if hits_metric.nil?
        end
      end

      # @api public
      # @return [List]
      def methods
        method_attr_list = remote.list_backend_methods id, hits.id
        if method_attr_list.respond_to?(:has_key?) && (errors = method_attr_list['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend methods not read', errors)
        end

        method_attr_list.map do |method_attrs|
          BackendMethod.new(id: method_attrs.fetch('id'), backend: self, attrs: method_attrs)
        end
      end

      def mapping_rules
        m_r = remote.list_backend_mapping_rules id
        if m_r.respond_to?(:has_key?) && (errors = m_r['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend mapping rules not read', errors)
        end

        m_r.map do |mr_attrs|
          BackendMappingRule.new(id: mr_attrs.fetch('id'), backend: self, attrs: mr_attrs)
        end
      end

      def update(b_attrs)
        new_attrs = remote.update_backend id, Helper.filter_params(VALID_PARAMS, b_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend not updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_backend id
      end

      def ==(other)
        remote.http_client.endpoint == other.remote.http_client.endpoint && id == other.id
      end

      def to_crd
        {
          'apiVersion' => 'capabilities.3scale.net/v1beta1',
          'kind' => 'Backend',
          'metadata' => {
            'annotations' => {
              '3scale_toolbox_created_at' => Time.now.utc.iso8601,
              '3scale_toolbox_version' => ThreeScaleToolbox::VERSION
            },
            'name' => crd_name
          },
          'spec' => {
            'name' => name,
            'systemName' => system_name,
            'privateBaseURL' => private_endpoint,
            'description' => description,
            'mappingRules' => mapping_rules.map(&:to_crd),
            'metrics' => metrics.each_with_object({}) do |metric, hash|
              hash[metric.system_name] = metric.to_crd
            end,
            'methods' => methods.each_with_object({}) do |method, hash|
              hash[method.system_name] = method.to_crd
            end
          }
        }
      end

      private

      def metrics_and_methods
        m_m = remote.list_backend_metrics id
        if m_m.respond_to?(:has_key?) && (errors = m_m['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend metrics not read', errors)
        end

        m_m
      end

      def fetch_backend_attrs
        raise ThreeScaleToolbox::InvalidIdError if id.zero?

        backend = remote.backend id
        if (errors = backend['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend attrs not read', errors)
        end

        backend
      end

      def crd_name
        # Should be DNS1123 subdomain name
        # TODO run validation for DNS1123
        # https://kubernetes.io/docs/concepts/overview/working-with-objects/names/
        "#{system_name.gsub(/[^[a-zA-Z0-9\-\.]]/, '.')}.#{Helper.random_lowercase_name}"
      end
    end
  end
end
