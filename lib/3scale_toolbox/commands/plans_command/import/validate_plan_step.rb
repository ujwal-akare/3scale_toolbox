module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ValidatePlanStep
          include Step
          ##
          # Creates if it does not exist, updates otherwise
          def call
            validate_product_metric_method_uniqueness!

            validate_backend_metric_method_uniqueness!

            validate_product_backend_usage_references!

            validate_limit_backend_references!

            validate_limit_product_references!

            validate_pricingrule_backend_references!

            validate_pricingrule_product_references!
          end

          private

          def validate_product_metric_method_uniqueness!
            system_name_list = (resource_product_metrics + resource_product_methods).map do |m|
              m.fetch('system_name')
            end
            if system_name_list.length != system_name_list.uniq.length
              raise ThreeScaleToolbox::Error, "Invalid content. " \
                "Product metrics and method system names must be unique."
            end
          end

          def validate_backend_metric_method_uniqueness!
            metric_list = resource_backend_metrics + resource_backend_methods
            backend_list = metric_list.map { |m| m.fetch('backend_system_name') }.uniq
            backend_list.each do |backend_system_name|
              backend_metric_list = metric_list.select do |m|
                m.fetch('backend_system_name') == backend_system_name
              end.map { |m| m.fetch('system_name') }

              if backend_metric_list.length != backend_metric_list.uniq.length
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Backend #{backend_system_name} contains metrics and method system names that are not unique"
              end
            end
          end

          def validate_product_backend_usage_references!
            metric_list = resource_backend_metrics + resource_backend_methods
            backend_list = metric_list.map { |m| m.fetch('backend_system_name') }.uniq
            backend_usages_list = service.backend_usage_list.map(&:backend).map(&:system_name)

            backend_list.each do |backend_system_name|
              unless backend_usages_list.include?(backend_system_name)
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Backend usage reference to backend #{backend_system_name} has not been found"
              end
            end
          end

          def validate_limit_backend_references!
            metric_list = resource_backend_metrics + resource_backend_methods
            limits_with_backend_ref = resource_limits.select{ |limit| limit.has_key? 'metric_backend_system_name'}
            limits_with_backend_ref.each do |limit|
              none = metric_list.none? do |m|
                m.fetch('system_name') == limit.fetch('metric_system_name') &&
                m.fetch('backend_system_name') == limit.fetch('metric_backend_system_name')
              end

              if none
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Limit with backend metric [#{limit.fetch('metric_system_name')}, #{limit.fetch('metric_backend_system_name')}] " \
                  "has not been found in metric or method list"
              end
            end
          end

          def validate_limit_product_references!
            metric_list = resource_product_metrics + resource_product_methods
            limits = resource_limits.reject { |limit| limit.has_key? 'metric_backend_system_name'}
            limits.each do |limit|
              if metric_list.none? { |m| m.fetch('system_name') == limit.fetch('metric_system_name') }
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "Limit with product metric [#{limit.fetch('metric_system_name')}] " \
                  "has not been found in metric or method list"
              end
            end
          end

          def validate_pricingrule_backend_references!
            metric_list = resource_backend_metrics + resource_backend_methods
            pr_with_backend_ref = resource_pricing_rules.select{ |pr| pr.has_key? 'metric_backend_system_name'}
            pr_with_backend_ref.each do |pr|
              none = metric_list.none? do |m|
                m.fetch('system_name') == pr.fetch('metric_system_name') &&
                m.fetch('backend_system_name') == pr.fetch('metric_backend_system_name')
              end

              if none
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "PricingRule with backend metric [#{pr.fetch('metric_system_name')}, #{pr.fetch('metric_backend_system_name')}] " \
                  "has not been found in metric or method list"
              end
            end
          end

          def validate_pricingrule_product_references!
            metric_list = resource_product_metrics + resource_product_methods
            prs = resource_pricing_rules.reject { |pr| pr.has_key? 'metric_backend_system_name'}
            prs.each do |pr|
              if metric_list.none? { |m| m.fetch('system_name') == pr.fetch('metric_system_name') }
                raise ThreeScaleToolbox::Error, "Invalid content. " \
                  "PricingRule with product metric [#{pr.fetch('metric_system_name')}] " \
                  "has not been found in metric or method list"
              end
            end
          end
        end
      end
    end
  end
end
