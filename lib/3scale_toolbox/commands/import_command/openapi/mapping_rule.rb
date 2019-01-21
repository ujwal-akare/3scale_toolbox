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
            operation[:path] + '$'
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
