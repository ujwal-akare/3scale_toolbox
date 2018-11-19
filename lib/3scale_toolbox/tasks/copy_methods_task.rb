module ThreeScaleToolbox
  module Tasks
    class CopyMethodsTask
      include CopyTask

      def call
        source_methods = source_service.methods
        copy_methods = copy_service.methods
        puts "original service hits metric #{source_service.hits['id']} has #{source_methods.size} methods"
        puts "copied service hits metric #{copy_service.hits['id']} has #{copy_methods.size} methods"
        m_m = ThreeScaleToolbox::Helper.array_difference(source_methods, copy_methods) do |method, copy|
          ThreeScaleToolbox::Helper.compare_hashes(method, copy, ['system_name'])
        end
        puts "creating #{m_m.size} missing methods on copied service"

        m_m.each do |method|
          filtered_method = ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name],
                                                                    method)
          copy_service.create_method(copy_service.hits['id'], filtered_method)
        end
      end
    end
  end
end
