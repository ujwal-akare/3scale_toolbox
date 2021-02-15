module ThreeScaleToolbox
  module Commands
    module BackendCommand
      module CopyCommand
        class CreateOrUpdateTargetBackendTask
          include Task

          # entrypoint
          def run
            backend = Entities::Backend.find(remote: target_remote, ref: target_backend_ref)

            if backend.nil?
              backend = Entities::Backend.create(remote: target_remote,
                                                 attrs: create_attrs)
            elsif backend == source_backend
              message = 'source and destination backends are the same: ' \
                "ID: #{source_backend.id} system_name: #{source_backend.attrs['system_name']}"
              warn "\e[1m\e[31mWarning: #{message}\e[0m"
            else
              backend.update update_attrs
            end

            # assign target backend for other tasks to have it available
            self.target_backend = backend

            logger.info "source backend ID: #{source_backend.id} system_name: #{source_backend.system_name}"
            logger.info "target backend ID: #{target_backend.id} system_name: #{target_backend.system_name}"
            report['backend_id'] = target_backend.id
          end

          def create_attrs
            source_backend.attrs.merge('system_name' => target_backend_ref)
          end

          def update_attrs
            source_backend.attrs.merge('system_name' => target_backend_ref)
          end

          def target_backend_ref
            option_target_system_name || source_backend.attrs.fetch('system_name')
          end
        end
      end
    end
  end
end
