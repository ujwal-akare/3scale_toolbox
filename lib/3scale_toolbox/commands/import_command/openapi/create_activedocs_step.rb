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
              logger.info 'Activedocs exists, update!'
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
              # the basePath field is updated to a new value only when overridden by optional param
              unless service.proxy['endpoint'].nil?
                api_spec.set_server_url(activedocs, URI.join(service.proxy.fetch('endpoint'), public_base_path))
              end
              # security definitions
              # just valid for oauth2 when oidc_issuer_endpoint is supplied
              if !api_spec.security.nil? && api_spec.security[:type] == 'oauth2' && !oidc_issuer_endpoint.nil?
                api_spec.set_oauth2_urls(activedocs, api_spec.security[:id], authorization_url, token_url)
              end
            end
          end

          def cleaned_issuer_endpoint
            return if oidc_issuer_endpoint.nil?

            issuer_uri = ThreeScaleToolbox::Helper.parse_uri(oidc_issuer_endpoint)
            issuer_uri.userinfo = ''
            issuer_uri.to_s
          end

          def authorization_url
            "#{cleaned_issuer_endpoint}/protocol/openid-connect/auth"
          end

          def token_url
            "#{cleaned_issuer_endpoint}/protocol/openid-connect/token"
          end
        end
      end
    end
  end
end
