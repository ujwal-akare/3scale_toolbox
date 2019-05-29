module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class BumpProxyVersionStep
          include Step

          ##
          # bumps proxy config version to propagate proxy settings updates
          def call
            # Proxy update is the mechanism to increase version of the proxy,
            # Hence propagating (mapping rules, poicies, oidc, auth) update to
            # latest proxy config, making available to gateway.

            # Currently it is done always because mapping rules, at least, are always created
            # So they need to be propagated
            proxy_settings = {
              # Adding harmless attribute to avoid empty body
              # update_proxy cannot be done with empty body
              # and must be done to increase proxy version
              # If proxy settings have not been changed since last update,
              # this request will not have effect and proxy config version will not be bumped.
              service_id: service.id
            }

            service.update_proxy proxy_settings
          end
        end
      end
    end
  end
end
