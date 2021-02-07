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
            # return silently if target metric hits does not exist
            return if target_backend.hits.nil?

            Entities::BackendMethod.create(backend: target_backend,
                                           parent_id: target_backend.hits.id,
                                           attrs:  method.attrs)
          rescue ThreeScaleToolbox::ThreeScaleApiError => e
            raise e unless ThreeScaleToolbox::Helper.system_name_already_taken_error?(e.apierrors)

            warn "[WARN] backend method #{method.attrs.fetch('system_name')} not created. " \
              'Backend metric with the same system_name exists.'
          end

          def source_methods
            source_backend.methods(source_backend.hits)
          end

          def target_methods
            target_backend.methods(target_backend.hits)
          end

          def missing_methods
            ThreeScaleToolbox::Helper.array_difference(source_methods, target_methods) do |source, target|
              source.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
