module ThreeScaleToolbox
  module Tasks
    class CopyMethodsTask
      include CopyTask

      def call
        source_methods = source.methods
        copy_methods = target.methods
        puts "original service hits metric #{source.hits['id']} has #{source_methods.size} methods"
        puts "copied service hits metric #{target.hits['id']} has #{copy_methods.size} methods"
        missing_methods = ThreeScaleToolbox::Helper.array_difference(source_methods, copy_methods) do |method, copy|
          ThreeScaleToolbox::Helper.compare_hashes(method, copy, ['system_name'])
        end
        puts "creating #{missing_methods.size} missing methods on copied service"

        missing_methods.each do |method|
          filtered_method = ThreeScaleToolbox::Helper.filter_params(%w[friendly_name system_name],
                                                                    method)
          target.create_method(target.hits['id'], filtered_method)
        end
      end
    end
  end
end
