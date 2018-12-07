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
            "#{operation[:verb].upcase}_#{operation[:path]}"
              .tr('}', '_')
              .tr('{', '_')
              .gsub(%r{/}, '_SLASH_')
          end

          def system_name
            friendly_name.downcase
          end
        end
      end
    end
  end
end
