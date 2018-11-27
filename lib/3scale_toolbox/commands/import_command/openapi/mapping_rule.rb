module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class MappingRule
          include Operation

          def to_h
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
            operation[:path]
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
