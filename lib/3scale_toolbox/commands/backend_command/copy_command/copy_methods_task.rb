module ThreeScaleToolbox
  module Commands
    module BackendCommand
      module CopyCommand
        class CopyMethodsTask
          include Task

          # entrypoint
          def run
            missing_methods.each(&method(:create_method))
            puts "created #{missing_methods.size} missing methods"
          end

          private

          def create_method(method)
            Entities::BackendMethod.create(backend: target_backend, attrs:  method.attrs)
          rescue ThreeScaleToolbox::ThreeScaleApiError => e
            raise e unless ThreeScaleToolbox::Helper.system_name_already_taken_error?(e.apierrors)

            warn "[WARN] backend method #{method.system_name} not created. " \
              'Backend metric with the same system_name exists.'
          end

          def missing_methods
            ThreeScaleToolbox::Helper.array_difference(source_backend.methods, target_backend.methods) do |source, target|
              source.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
