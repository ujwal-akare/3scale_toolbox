module ThreeScaleToolbox
  module Entities
    class Method
      class << self
        def create(service:, attrs:)
          method_attrs = service.remote.create_method service.id, service.hits.id, attrs
          if (errors = method_attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Method has not been created', errors)

          end

          new(id: method_attrs.fetch('id'), service: service, attrs: method_attrs)
        end

        # ref can be system_name or method_id
        def find(service:, ref:)
          new(id: ref, service: service).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(service: service, system_name: ref)
        end

        def find_by_system_name(service:, system_name:)
          service.methods.find { |m| m.system_name == system_name }
        end
      end

      attr_reader :id, :service, :remote

      def initialize(id:, service:, attrs: nil)
        @id = id.to_i
        @service = service
        @remote = service.remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= method_attrs
      end

      def system_name
        attrs['system_name'] 
      end

      def disable
        Metric.new(id: id, service: service).disable
      end

      def enable
        Metric.new(id: id, service: service).enable
      end

      def update(m_attrs)
        new_attrs = remote.update_method(service.id, hits_id, id, m_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Method has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_method service.id, hits_id, id
      end

      private

      def hits_id
        service.hits.id
      end

      def method_attrs
        method = remote.show_method service.id, hits_id, id
        if (errors = method['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Method not read', errors)
        end

        method
      end
    end
  end
end
