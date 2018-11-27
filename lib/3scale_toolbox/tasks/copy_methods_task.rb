module ThreeScaleToolbox
  module Tasks
    class CopyMethodsTask
      include CopyTask

      def call
        source_methods = source.methods
        target_methods = target.methods
        target_hits_metric_id = target.hits['id']
        puts "original service hits metric #{source.hits['id']} has #{source_methods.size} methods"
        puts "target service hits metric #{target_hits_metric_id} has #{target_methods.size} methods"
        missing = missing_methods(source_methods, target_methods).each do |method|
          filtered_method = ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name],
                                                                    method)
          target.create_method(target_hits_metric_id, filtered_method)
        end
        puts "created #{missing.size} missing methods on target service"
      end

      private

      def missing_methods(source_methods, target_methods)
        ThreeScaleToolbox::Helper.array_difference(source_methods, target_methods) do |method, target|
          ThreeScaleToolbox::Helper.compare_hashes(method, target, ['system_name'])
        end
      end
    end
  end
end
