module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module Step
          attr_reader :context

          def initialize(context)
            @context = context
          end

          # Can be nil on initialization time and not nil afterwards
          # method to fetch from context required
          def service
            context[:target]
          end

          def service=(service)
            context[:target] = service
          end

          def api_spec
            context[:api_spec]
          end

          def threescale_client
            context[:threescale_client]
          end

          def operations
            # api_spec.operations are readonly
            # store operations in context
            # each operation can be extended with extra information to be used later
            context[:operations] ||= api_spec.operations
          end

          def target_system_name
            # could be nil
            context[:target_system_name]
          end

          def resource
            context[:api_spec_resource]
          end

          def system_name_already_taken_error?(error)
            Array(Hash(error)['system_name']).any? { |msg| msg.match(/has already been taken/) }
          end

          def security
            api_spec.security
          end

          def oidc_issuer_endpoint
            context[:oidc_issuer_endpoint]
          end

          def default_credentials_userkey
            context[:default_credentials_userkey]
          end

          def override_private_basepath
            context[:override_private_basepath]
          end
        end
      end
    end
  end
end
