module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyMethodsTask
          include Task

          def call
            puts "original service hits metric #{source_hits.fetch('id')} has #{source_methods.size} methods"
            puts "target service hits metric #{target_hits.fetch('id')} has #{target_methods.size} methods"
            missing_methods.each(&method(:create_method))
            puts "created #{missing_methods.size} missing methods on target service"
            invalidate_target_methods if missing_methods.size.positive?
          end

          private

          def create_method(method)
            Entities::Method.create(
              service: target,
              parent_id: target_hits.fetch('id'),
              attrs: ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name], method)
            )
          rescue ThreeScaleToolbox::ThreeScaleApiError => e
            raise e unless ThreeScaleToolbox::Helper.system_name_already_taken_error?(e.apierrors)

            warn "[WARN] method #{method.fetch('system_name')} not created. " \
              'Metric with the same system_name exists.'
          end

          def missing_methods
            @missing_methods ||= ThreeScaleToolbox::Helper.array_difference(source_methods, target_methods) do |method, target|
              ThreeScaleToolbox::Helper.compare_hashes(method, target, ['system_name'])
            end
          end
        end
      end
    end
  end
end
