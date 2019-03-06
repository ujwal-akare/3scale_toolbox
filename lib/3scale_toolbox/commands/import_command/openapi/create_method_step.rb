module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateMethodsStep
          include Step

          def call
            hits_metric_id = service.hits['id']
            operations.each do |op|
              res = service.create_method(hits_metric_id, op.method)
              metric_id = res['id']
              # if method system_name exists, ignore error and get metric_id
              # Make operation indempotent
              if (errors = res['errors'])
                raise Error, "Metohd has not been saved. #{errors}" \
                  unless system_name_already_taken_error? errors

                metric_id = method_id_by_system_name[op.method['system_name']]
              end

              op.set(:metric_id, metric_id)
            end
          end

          private

          def method_id_by_system_name
            @method_id_by_system_name ||= service.methods.each_with_object({}) do |method, acc|
              acc[method['system_name']] = method['id']
            end
          end
        end
      end
    end
  end
end
