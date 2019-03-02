module ThreeScaleToolbox
  module Tasks
    class CopyActiveDocsTask
      include CopyTask

      def call
        puts 'copying all service ActiveDocs'

        target_activedocs = source.list_activedocs.map do |source_activedoc|
          source_activedoc.clone.tap do |target_activedoc|
            target_activedoc.delete('id')
            target_activedoc['service_id'] = target.id
            target_activedoc['system_name'] = "#{target_activedoc['system_name']}#{target.id}"
          end
        end

        target_activedocs.each do |ad|
          res = target.remote.create_activedocs(ad)
          raise ThreeScaleToolbox::Error, "ActiveDocs has not been created. Errors: #{res['errors']}" unless res['errors'].nil?
        end
      end
    end
  end
end
