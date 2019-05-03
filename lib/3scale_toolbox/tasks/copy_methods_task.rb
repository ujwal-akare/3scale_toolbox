module ThreeScaleToolbox
  module Tasks
    class CopyMethodsTask
      include CopyTask

      def call
        source_hits_id = source.hits['id']
        target_hits_id = target.hits['id']
        source_methods = source.methods source_hits_id
        target_methods = target.methods target_hits_id
        puts "original service hits metric #{source_hits_id} has #{source_methods.size} methods"
        puts "target service hits metric #{target_hits_id} has #{target_methods.size} methods"
        missing = missing_methods(source_methods, target_methods).each do |method|
          Entities::Method.create(
            service: target,
            parent_id: target_hits_id,
            attrs: ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name], method)
          )
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
