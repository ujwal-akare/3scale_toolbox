module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateBackendStep
          include Step

          ##
          # Creates backend with a given system_name
          # If the backend already exists, update basic settings like name and description
          def call
            # Update backend and update context
            self.backend = Entities::Backend.find_by_system_name(remote: threescale_client,
                                                                 system_name: system_name)
            if backend.nil?
              # Create service and update context
              self.backend = Entities::Backend.create(remote: threescale_client,
                                                      attrs: create_attrs)
            else
              backend.update(update_attrs)
            end

            report['id'] = backend.id
            report['system_name'] = backend.system_name
            report['private_endpoint'] = backend.private_endpoint
          end

          private

          def create_attrs
            {
              'name' => title,
              'system_name' => system_name,
              'description' => description,
              'private_endpoint' => private_endpoint
            }
          end

          def update_attrs
            {
              'name' => title,
              'description' => description,
              'private_endpoint' => private_endpoint
            }
          end

          def system_name
            target_system_name || title.downcase.gsub(/[^\w]/, '_')
          end

          def private_endpoint
            override_private_base_url || host
          end

          def title
            api_spec.title
          end

          def description
            api_spec.description
          end
        end
      end
    end
  end
end
