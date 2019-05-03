module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class CreateActiveDocsStep
          include Step

          def call
            active_doc = {
              name: api_spec.title,
              system_name: activedocs_system_name,
              service_id: service.id,
              body: JSON.pretty_generate(rewritten_openapi),
              description: api_spec.description,
              published: context[:activedocs_published],
              skip_swagger_validations: context[:skip_openapi_validation]
            }

            res = threescale_client.create_activedocs(active_doc)
            # Make operation indempotent
            if (errors = res['errors'])
              raise ThreeScaleToolbox::Error, "ActiveDocs has not been created. #{errors}" \
                unless ThreeScaleToolbox::Helper.system_name_already_taken_error? errors

              # if activedocs system_name exists, ignore error, update activedocs
              puts 'Activedocs exists, update!'
              update_res = threescale_client.update_activedocs(find_activedocs_id, active_doc)
              raise ThreeScaleToolbox::Error, "ActiveDocs has not been updated. #{update_res['errors']}" unless update_res['errors'].nil?
            end
          end

          private

          def activedocs_system_name
            @activedocs_system_name ||= service.attrs['system_name']
          end

          def find_activedocs_id
            activedocs = get_current_service_activedocs
            raise ThreeScaleToolbox::Error, "Could not find activedocs with system_name: #{activedocs_system_name}" if activedocs.empty?

            activedocs.dig(0, 'id')
          end

          def get_current_service_activedocs
            threescale_client.list_activedocs.select do |activedoc|
              activedoc['system_name'] == activedocs_system_name
            end
          end

          def rewritten_openapi
            # Updates on copy
            # Other processing steps can work with original openapi spec
            Helper.hash_deep_dup(resource).tap do |activedocs|
              # public production base URL
              URI(service.proxy.fetch('endpoint')).tap do |uri|
                activedocs['host'] = "#{uri.host}:#{uri.port}"
                activedocs['schemes'] = [uri.scheme]
              end

              # the basePath field is updated to a new value only when overriden by optional param
              activedocs['basePath'] = api_spec.public_base_path

              # security definitions
              # just valid for oauth2 when oidc_issuer_endpoint is supplied
              if !security.nil? && security.type == 'oauth2' && !oidc_issuer_endpoint.nil?
                # authorizationURL
                if %w[implicit accessCode].include?(security.flow)
                  activedocs['securityDefinitions'][security.id]['authorizationUrl'] = authorization_url
                end

                # tokenUrl
                if %w[password application accessCode].include?(security.flow)
                  activedocs['securityDefinitions'][security.id]['tokenUrl'] = token_url
                end
              end
            end
          end

          def authorization_url
            "#{oidc_issuer_endpoint}/protocol/openid-connect/auth"
          end

          def token_url
            "#{oidc_issuer_endpoint}/protocol/openid-connect/token"
          end
        end
      end
    end
  end
end
