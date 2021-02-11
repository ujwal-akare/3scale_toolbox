module ThreeScaleToolbox
  module CRD
    module BackendSerializer
      def to_cr
        {
          'apiVersion' => 'capabilities.3scale.net/v1beta1',
          'kind' => 'Backend',
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
            'privateBaseURL' => private_endpoint,
            'description' => description,
            'mappingRules' => mapping_rules.map(&:to_cr),
            'metrics' => metrics.each_with_object({}) do |metric, hash|
              hash[metric.system_name] = metric.to_cr
            end,
            'methods' => methods.each_with_object({}) do |method, hash|
              hash[method.system_name] = method.to_cr
            end
          }
        }
      end

      def cr_name
        # Should be DNS1123 subdomain name
        # TODO run validation for DNS1123
        # https://kubernetes.io/docs/concepts/overview/working-with-objects/names/
        "#{system_name.gsub(/[^[a-zA-Z0-9\-\.]]/, '.')}.#{Helper.random_lowercase_name}"
      end
    end
  end
end
