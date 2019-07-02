module ThreeScaleToolbox
  module Entities
    class ActiveDocs
      class << self
        def create(remote:, attrs:)
          activedocs_res = create_activedocs(remote: remote, attrs: attrs)
          new(id: activedocs_res.fetch('id'), remote: remote, attrs: activedocs_res)
        end

        # ref can be system_name or activedocs_id
        def find(remote:, ref:)
          new(id: ref, remote: remote).tap(&:attrs)
        rescue ThreeScaleToolbox::ActiveDocsNotFoundError
          find_by_system_name(remote: remote, system_name: ref)
        end

        def find_by_system_name(remote:, system_name:)
          activedocs_list = remote.list_activedocs

          if activedocs_list.respond_to?(:has_key?) && (errors = activedocs_list['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('ActiveDocs list not read', errors)
          end

          res_attrs = activedocs_list.find { |svc| svc['system_name'] == system_name }
          return if res_attrs.nil?

          new(id: res_attrs.fetch('id'), remote: remote, attrs: res_attrs)
        end

        private

        def create_activedocs(remote:, attrs:)
          activedocs_res = remote.create_activedocs(attrs)
          if (errors = activedocs_res['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('ActiveDocs has not been created', errors)
          end

          activedocs_res
        end
      end

      attr_reader :id, :remote

      def initialize(id:, remote:, attrs: nil)
        @id = id.to_i
        @remote = remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= activedoc_attrs
      end

      def delete
        remote.delete_activedocs id
      end

      def update(a_attrs)
        new_attrs = remote.update_activedocs(id, a_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ActiveDocs has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      private

      def activedoc_attrs
        activedocs_list = remote.list_activedocs

        if activedocs_list.respond_to?(:has_key?) && (errors = activedocs_list['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('ActiveDocs list not read', errors)
        end

        res_attrs = activedocs_list.find { |adocs| adocs.fetch('id') == id }
        if res_attrs.nil?
          raise ThreeScaleToolbox::ActiveDocsNotFoundError.new(id)
        end

        res_attrs
      end
    end
  end
end
