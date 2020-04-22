module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyServiceProxyTask
          include Task

          def call
            target.update_proxy target_proxy_attrs
            target.update_oidc source.oidc if source.attrs['backend_version'] == 'oidc'
            puts "updated proxy of #{target.id} to match the original"
          end

          def target_proxy_attrs
            if source.attrs['deployment_option'] == 'hosted'
              # For services with "hosted" deployment config, 
              # "Public Base URL" should not be copied, mainly because public base URL is self-assigned.
              # Two 3scale products (aka services) cannot be served using the same public base URL.
              source_proxy.dup.delete_if { |key, _v| %w[endpoint sandbox_endpoint].include? key }
            else
              source_proxy
            end
          end

          def source_proxy
            @source_proxy ||= source.proxy
          end
        end
      end
    end
  end
end
