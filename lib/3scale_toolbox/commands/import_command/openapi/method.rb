module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module Method

          def method
            {
              'friendly_name' => friendly_name,
              'system_name' => system_name
            }
          end

          def friendly_name
            operation[:operationId] || operation_id
          end

          def system_name
            friendly_name.downcase
          end

          def operation_id
            "#{operation[:verb]}#{operation[:path].gsub(/[^\w]/, '')}"
          end
        end
      end
    end
  end
end
