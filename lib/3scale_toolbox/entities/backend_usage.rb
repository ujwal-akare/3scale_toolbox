module ThreeScaleToolbox
  module Entities
    ##
    # BackendUsage represents Product - Backend mapping entry
    class BackendUsage
      include CRD::BackendUsage

      CREATE_PARAMS = %w[path backend_api_id].freeze
      public_constant :CREATE_PARAMS
      UPDATE_PARAMS = %w[path].freeze
      public_constant :UPDATE_PARAMS

      class << self
        def create(product:, attrs:)
          resp = product.remote.create_backend_usage(
            product.id,
            Helper.filter_params(CREATE_PARAMS, attrs)
          )
          if (errors = resp['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend usage has not been created',
                                                            errors)
          end

          new(id: resp.fetch('id'), product: product, attrs: resp)
        end

        def find_by_path(product:, path:)
          resp = product.remote.list_backend_usages product.id
          if resp.respond_to?(:has_key?) && (errors = resp['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend usage list error', errors)
          end

          backend_usage_attrs = resp.find { |bus| bus['path'] == path }
          return if backend_usage_attrs.nil?

          new(id: backend_usage_attrs.fetch('id'), product: product, attrs: backend_usage_attrs)
        end

        def from_cr(id, service_id, backend_id, cr)
          {
            'id' => id,
            'path' => cr['path'],
            'service_id' => service_id,
            'backend_id' => backend_id
          }
        end
      end

      attr_reader :id, :product, :remote

      def initialize(id:, product:, attrs: nil)
        @id = id.to_i
        @product = product
        @remote = product.remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= fetch_attrs
      end

      def path
        attrs['path']
      end

      def backend_id
        # 3scale API returns 'backend_id'
        # 3scale API only accepts 'backend_api_id' as params on create endpoint
        # good job
        attrs['backend_id']
      end

      def update(usage_attrs)
        new_attrs = remote.update_backend_usage(
          product.id, id,
          Helper.filter_params(UPDATE_PARAMS, usage_attrs)
        )
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Backend usage not been updated', errors)
        end

        if new_attrs['service_id'] != product.id
          raise ThreeScaleToolbox::Error, 'Backend usage product updated'
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_backend_usage product.id, id
      end

      def backend
        Backend.new(id: backend_id, remote: remote)
      end

      private

      def fetch_attrs
        raise ThreeScaleToolbox::InvalidIdError if id.zero?

        resp = remote.backend_usage product.id, id
        if (errors = resp['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Product backend usage not read', errors)
        end

        resp
      end
    end
  end
end
