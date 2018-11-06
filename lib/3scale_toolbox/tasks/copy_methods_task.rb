module ThreeScaleToolbox
  module Tasks
    class CopyMethodsTask
      include CallableTask
      include CopyTask

      def call
        m_m = missing_methods(source_service.methods,
                              copy_service.methods)
        puts "creating #{m_m.size} missing methods on copied service"

        m_m.each do |method|
          filtered_method = ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name],
                                                                    method)
          copy_service.create_method(copy_service.hits['id'], filtered_method)
        end
      end

      private

      def missing_methods(source_methods, copy_methods)
        ThreeScaleToolbox::Helper.array_difference(source_methods, copy_methods) do |method, copy|
          ThreeScaleToolbox::Helper.compare_hashes(method, copy, ['system_name'])
        end
      end
    end
  end
end
