module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module Step
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def report
            context[:report] ||= {}
          end

          def backend
            context[:backend_target]
          end

          def backend=(backend_obj)
            context[:backend_target] = backend_obj
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
            context[:operations] ||= build_3scale_operations
          end

          def build_3scale_operations
            api_spec.operations.map do |op|
              Operation.new(
                base_path: base_path,
                public_base_path: public_base_path,
                path: op[:path],
                verb: op[:verb],
                operation_id: op[:operation_id],
                description: op[:description],
                prefix_matching: prefix_matching,
              )
            end
          end

          def target_system_name
            # could be nil
            context[:target_system_name]
          end

          def resource
            context[:api_spec_resource]
          end

          def oidc_issuer_type
            context[:oidc_issuer_type]
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

          def override_public_basepath
            context[:override_public_basepath]
          end

          def production_public_base_url
            context[:production_public_base_url]
          end

          def staging_public_base_url
            context[:staging_public_base_url]
          end

          def override_private_base_url
            context[:override_private_base_url]
          end

          def backend_api_secret_token
            context[:backend_api_secret_token]
          end

          def backend_api_host_header
            context[:backend_api_host_header]
          end

          def prefix_matching
            context[:prefix_matching]
          end

          def host
            return if api_spec.host.nil?

            "#{api_spec.scheme || 'https'}://#{api_spec.host}"
          end

          def base_path
            api_spec.base_path || '/'
          end

          def public_base_path
            override_public_basepath || base_path
          end

          def private_base_path
            override_private_basepath || base_path
          end

          def logger
            context[:logger]
          end
        end
      end
    end
  end
end
