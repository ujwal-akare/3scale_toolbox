module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateServiceStep
          include Step

          def call
            service_attr = default_service_settings
            service_attr['name'] = service_name
            service_attr['description'] = service_description

            # Create service and update context
            context[:service] = Entities::Service.create(remote: threescale_client,
                                                         service: service_attr,
                                                         system_name: service_system_name)
            puts "Created service id: #{context[:service].id}, name: #{service_name}"
          end

          private

          def default_service_settings
            {}
          end

          def service_name
            api_spec.title
          end

          def service_description
            api_spec.description
          end

          def service_system_name
            service_name.downcase.tr(' ', '_')
          end
        end
      end
    end
  end
end
