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

          def apply_target_activedoc(source_activedoc)
            activedocs = Entities::ActiveDocs.find_by_system_name(remote: target.remote,
                                                                  system_name: source_activedoc.system_name)
            if activedocs.nil?
              activedocs = Entities::ActiveDocs.create(remote: target.remote, attrs: create_attrs(source_activedoc))
              activedocs_report[activedocs.system_name] = { 'id' => activedocs.id, 'status' => 'created' }
            elsif activedocs.attrs.fetch('service_id') == target.id
              activedocs.update(update_attrs(source_activedoc))
              activedocs_report[activedocs.system_name] = { 'id' => activedocs.id, 'status' => 'updated' }
            else
              # activedocs with same system_name exists, but now owned by target service
              new_attrs = create_attrs(source_activedoc)
              new_attrs['system_name'] = "#{source_activedoc.system_name}#{target.id}"
              activedocs = Entities::ActiveDocs.create(remote: target.remote, attrs: new_attrs)
              activedocs_report[activedocs.system_name] = { 'id' => activedocs.id, 'status' => 'created' }
            end
          end

          def update_attrs(activedoc)
            create_attrs(activedoc)
          end

          def create_attrs(activedoc)
            # keep same system_name
            new_attrs = activedoc.attrs.reject { |key, _| %w[id created_at updated_at].include? key }
            new_attrs.tap do |attrs|
              attrs['service_id'] = target.id
            end
          end
        end
      end
    end
  end
end
