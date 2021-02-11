module ThreeScaleToolbox
  module Entities
    class BackendMethod
      include CRD::BackendMethod

      VALID_PARAMS = %w[friendly_name system_name description].freeze
      public_constant :VALID_PARAMS

      class << self
        def create(backend:, attrs:)
          method = backend.remote.create_backend_method(backend.id, backend.hits.id,
                                                        Helper.filter_params(VALID_PARAMS, attrs))
          if (errors = method['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend Method has not been created',
                                                            errors)
          end

          new(id: method.fetch('id'), backend: backend, attrs: method)
        end

        # ref can be system_name or method_id
        def find(backend:, ref:)
          new(id: ref, backend: backend).tap(&:attrs)
        rescue ThreeScaleToolbox::InvalidIdError, ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(backend: backend, system_name: ref)
        end

        def find_by_system_name(backend:, system_name:)
          backend.methods.find { |m| m.system_name == system_name }
        end

        def from_cr(id, system_name, cr)
          {
            'id' => id,
            'name' => cr['friendlyName'],
            'friendly_name' => cr['friendlyName'],
            'system_name' => system_name,
            'description' => cr['description'],
          }
        end
      end

      attr_reader :id, :backend, :remote

      def initialize(id:, backend:, attrs: nil)
        @id = id.to_i
        @backend = backend
        @remote = backend.remote
        @attrs = process_attrs(attrs)
      end

      def attrs
        @attrs ||= process_attrs(method_attrs)
      end

      def system_name
        attrs['system_name']
      end

      def friendly_name
        attrs['friendly_name']
      end

      def description
        attrs['description']
      end

      def update(m_attrs)
        new_attrs = remote.update_backend_method(backend.id, hits_id, id,
                                                 Helper.filter_params(VALID_PARAMS, m_attrs))
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend Method has not been updated',
                                                          errors)
        end

        # update current attrs
        @attrs = process_attrs(new_attrs)
      end

      def delete
        remote.delete_backend_method backend.id, hits_id, id
      end

      private

      def hits_id
        backend.hits.id
      end

      def process_attrs(metric_attrs)
        return if metric_attrs.nil?

        # system_name: my_metric_02.45498 -> system_name: my_metric_02
        metric_attrs.merge('system_name' => metric_attrs.fetch('system_name', '').partition('.').first)
      end

      def method_attrs
        raise ThreeScaleToolbox::InvalidIdError if id.zero?

        method = remote.backend_method backend.id, hits_id, id
        if (errors = method['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend method not read', errors)
        end

        method
      end
    end
  end
end
