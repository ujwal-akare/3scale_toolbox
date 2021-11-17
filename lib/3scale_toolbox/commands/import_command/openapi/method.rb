module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module Method
          def method
            {
              'friendly_name' => friendly_name,
              'description' => description,
              'system_name' => system_name
            }
          end

          def friendly_name
            operation[:operation_id] || operation_id
          end

          def system_name
            friendly_name.downcase.gsub(/[^\w]/, '_')
          end

          def operation_id
            "#{operation[:verb]}#{operation[:path].gsub(/[^\w]/, '')}"
          end

          def description
            String(operation[:description])
          end
        end
      end
    end
  end
end
