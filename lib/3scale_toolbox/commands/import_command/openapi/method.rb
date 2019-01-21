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
            operation[:operationId]
          end

          def system_name
            friendly_name.downcase
          end
        end
      end
    end
  end
end
