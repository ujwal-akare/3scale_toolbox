module ThreeScaleToolbox
  module Entities
    class Method
      class << self
        def create(service:, parent_id:, attrs:)
          method = service.remote.create_method service.id, parent_id, attrs
          if (errors = method['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Method has not been created', errors)

          end

          new(id: method.fetch('id'), parent_id: parent_id, service: service, attrs: method)
        end

        # ref can be system_name or method_id
        def find(service:, parent_id:, ref:)
          new(id: ref, parent_id: parent_id, service: service).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(service: service, parent_id: parent_id, system_name: ref)
        end

        def find_by_system_name(service:, parent_id:, system_name:)
          method = service.methods(parent_id).find { |m| m['system_name'] == system_name }
          return if method.nil?

          new(id: method.fetch('id'), parent_id: parent_id, service: service, attrs: method)
        end
      end

      attr_reader :id, :parent_id, :service, :remote

      def initialize(id:, parent_id:, service:, attrs: nil)
        @id = id
        @service = service
        @parent_id = parent_id
        @remote = service.remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= method_attrs
      end

      def disable
        Metric.new(id: id, service: service).disable
      end

      def enable
        Metric.new(id: id, service: service).enable
      end

      def update(m_attrs)
        new_attrs = remote.update_method(service.id, parent_id, id, m_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Method has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_method service.id, parent_id, id
      end

      private

      def method_attrs
        method = remote.show_method service.id, parent_id, id
        if (errors = method['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Method not read', errors)
        end

        method
      end
    end
  end
end
