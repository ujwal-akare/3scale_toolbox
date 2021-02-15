module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyActiveDocsTask
          include Task

          def call
            logger.info 'copying all service ActiveDocs'

            source.activedocs.each(&method(:apply_target_activedoc))
          end

          private

          def apply_target_activedoc(attrs)
            activedocs = Entities::ActiveDocs.find_by_system_name(remote: target.remote,
                                                                  system_name: attrs['system_name'])
            if activedocs.nil?
              activedocs = Entities::ActiveDocs.create(remote: target.remote, attrs: create_attrs(attrs))
              activedocs_report[activedocs.system_name] = { 'id' => activedocs.id, 'status' => 'created' }
            elsif activedocs.attrs.fetch('service_id') == target.id
              activedocs.update(update_attrs(attrs))
              activedocs_report[activedocs.system_name] = { 'id' => activedocs.id, 'status' => 'updated' }
            else
              # activedocs with same system_name exists, but now owned by target service
              new_attrs = create_attrs(attrs)
              new_attrs['system_name'] = "#{attrs['system_name']}#{target.id}"
              activedocs = Entities::ActiveDocs.create(remote: target.remote, attrs: new_attrs)
              activedocs_report[activedocs.system_name] = { 'id' => activedocs.id, 'status' => 'created' }
            end
          end

          def update_attrs(old_attrs)
            create_attrs(old_attrs)
          end

          def create_attrs(old_attrs)
            # keep same system_name
            new_attrs = old_attrs.reject { |key, _| %w[id created_at updated_at].include? key }
            new_attrs.tap do |attrs|
              attrs['service_id'] = target.id
            end
          end
        end
      end
    end
  end
end
