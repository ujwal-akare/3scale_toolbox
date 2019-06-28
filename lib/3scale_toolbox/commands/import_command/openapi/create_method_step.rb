module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateMethodsStep
          include Step

          def call
            missing_operations.each do |op|
              method = Entities::Method.create(service: service, parent_id: hits_metric_id,
                                               attrs: op.method)
              op.set(:metric_id, method.id)
            end

            existing_operations.each do |op|
              method_attrs = methods_index.fetch(op.method['system_name'])
              method = Entities::Method.new(
                id: method_attrs.fetch('id'),
                parent_id: hits_metric_id,
                service: service
              )
              method.update(op.method)
              op.set(:metric_id, method.id)
            end
          end

          private

          def hits_metric_id
            @hits_metric_id ||= service.hits['id']
          end

          def methods_index
            @methods_index ||= service.methods(hits_metric_id).each_with_object({}) do |method, acc|
              acc[method['system_name']] = method
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
