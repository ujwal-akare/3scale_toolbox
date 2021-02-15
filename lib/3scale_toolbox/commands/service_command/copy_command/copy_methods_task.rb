module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyMethodsTask
          include Task

          def call
            logger.info "original service hits metric #{source.hits.id} has #{source.methods.size} methods"
            logger.info "target service hits metric #{target.hits.id} has #{target.methods.size} methods"
            missing_methods.each(&method(:create_method))
            logger.info "created #{missing_methods.size} missing methods on target service"
            report['missing_methods_created'] = missing_methods.size
          end

          private

          def create_method(method)
            Entities::Method.create(
              service: target,
              attrs: ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name], method.attrs)
            )
          rescue ThreeScaleToolbox::ThreeScaleApiError => e
            raise e unless ThreeScaleToolbox::Helper.system_name_already_taken_error?(e.apierrors)

            warn "[WARN] method #{method.system_name} not created. " \
              'Metric with the same system_name exists.'
          end

          def missing_methods
            @missing_methods ||= ThreeScaleToolbox::Helper.array_difference(source.methods, target.methods) do |method, target|
              method.system_name == target.system_name
            end
          end
        end
      end
    end
  end
end
