module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateBackendMethodsStep
          include Step

          def call
            missing_operations.each do |op|
              method = Entities::BackendMethod.create(backend: backend, attrs: op.method)
              op.set(:metric_id, method.id)
            end

            existing_operations.each do |op|
              method_attrs = methods_index.fetch(op.method['system_name']).attrs
              method = Entities::BackendMethod.new(id: method_attrs.fetch('id'), backend: backend)
              method.update(op.method)
              op.set(:metric_id, method.id)
            end
          end

          private

          def methods_index
            @methods_index ||= backend.methods.each_with_object({}) do |method, acc|
              acc[method.system_name] = method
            end
          end

          def missing_operations
            operations.reject { |op| methods_index.key? op.method['system_name'] }
          end

          def existing_operations
            operations.select { |op| methods_index.key? op.method['system_name'] }
          end
        end
      end
    end
  end
end
