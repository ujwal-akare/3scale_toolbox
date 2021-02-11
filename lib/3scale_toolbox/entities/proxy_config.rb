module ThreeScaleToolbox
  module Entities
    class ProxyConfig
      class << self
        def find(service:, environment:, version:)
          new(service: service, environment: environment, version: version).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end

        def find_latest(service:, environment:)
          proxy_cfg = service.remote.proxy_config_latest(service.id, environment)
          if (errors = proxy_cfg['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfig find_latest not read', errors)
          end
          new(service: service, environment: environment, version: proxy_cfg["version"], attrs: proxy_cfg)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end
      end

      attr_reader :remote, :service, :environment, :version

      def initialize(environment:, service:, version:, attrs: nil)
        @remote = service.remote
        @service = service
        @environment = environment
        @version = version
        @attrs = attrs
      end

      def attrs
        @attrs ||= proxy_config_attrs
      end

      def promote(to:)
        res = remote.promote_proxy_config(service.id, environment, version, to)

        if (errors = res['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfig not promoted', errors)
        end
        res
      end

      private

      def proxy_config_attrs
        proxy_cfg = remote.show_proxy_config(service.id, environment, version)

        if (errors = proxy_cfg['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ProxyConfig not read', errors)
        end
        proxy_cfg
      end
    end
  end
end
