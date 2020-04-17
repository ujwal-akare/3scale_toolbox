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
              # for services with "hosted" deployment config,
              # apicast gateway addresses should not be copied.
              # Gateway addresses includes service's id and if copied, the service will not
              # have visibility.
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
