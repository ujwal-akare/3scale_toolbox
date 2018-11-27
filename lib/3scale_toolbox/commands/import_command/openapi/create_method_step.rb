module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateMethodsStep
          include Step

          def call
            hits_metric_id = service.hits['id']
            api_spec.methods.each do |method|
              res = service.create_method(hits_metric_id, method.to_h)
              method.set(:metric_id, res['id'])
            end
          end
        end
      end
    end
  end
end
