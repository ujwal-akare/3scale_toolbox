module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CreateOrUpdateTargetServiceTask
          include Task

          def call
            service = Entities::Service.find(remote: target_remote,
                                             ref: target_service_ref)
            if service == source
              raise ThreeScaleToolbox::Error, 'Source and destination services are the same: ' \
                "ID: #{source.id} system_name: #{source.attrs['system_name']}"
            end

            if service.nil?
              service = Entities::Service.create(remote: target_remote,
                                                 service_params: create_attrs)
              # Notify that mapping rules should be deleted before being copied
              force_delete_mapping_rules
            else
              service.update update_attrs
            end

            # assign target service for other tasks to have it available
            self.target = service

            logger.info "new service id #{service.id}"
            report['product_id'] = service.id
          end

          private

          def target_service_ref
            option_target_system_name || source.attrs.fetch('system_name')
          end

          def create_attrs
            source.attrs.merge('system_name' => target_service_ref)
          end

          def update_attrs
            source.attrs.merge('system_name' => target_service_ref)
          end
        end
      end
    end
  end
end
