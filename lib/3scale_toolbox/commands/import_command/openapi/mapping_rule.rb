module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module MappingRule
          def mapping_rule
            {
              'pattern' => pattern,
              'http_method' => http_method,
              'delta' => delta,
              'metric_id' => metric_id
            }
          end

          def http_method
            operation[:verb].upcase
          end

          def pattern
            # apply strict matching
            "#{raw_pattern}$"
          end

          def raw_pattern
            # According OAS 2.0: path MUST begin with a slash
            "#{public_base_path}#{operation[:path]}"
          end

          def public_base_path
            # remove the last slash of the basePath
            operation[:public_base_path].gsub(%r{/$}, '')
          end

          def delta
            1
          end

          def metric_id
            operation[:metric_id]
          end
        end
      end
    end
  end
end
