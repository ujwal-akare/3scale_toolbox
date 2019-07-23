module ThreeScaleToolbox
  module Entities
    class Application
      class << self
        def create(remote:, account_id:, plan_id:, app_attrs: nil)
          attrs = remote.create_application(account_id, app_attrs, plan_id: plan_id)
          if (errors = attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Application has not been created', errors)
          end

          new(id: attrs.fetch('id'), remote: remote, attrs: attrs)
        end

        # ref can be
        # * User_key (API key)
        # * App_id (from app_id/app_key pair) / Client ID (for OAuth and OpenID Connect authentication modes)
        # * Application internal id
        def find(remote:, service_id: nil, ref:)
          app = find_by_user_key(remote, service_id, ref)
          return app unless app.nil?

          app = find_by_app_id(remote, service_id, ref)
          return app unless app.nil?

          app = find_by_id(remote, service_id, ref)
          return app unless app.nil?

          nil
        end

        def find_by_id(remote, service_id, id)
          generic_find(remote, service_id, :id, id)
        end

        def find_by_user_key(remote, service_id, user_key)
          generic_find(remote, service_id, :user_key, user_key)
        end

        def find_by_app_id(remote, service_id, app_id)
          generic_find(remote, service_id, :application_id, app_id)
        end

        private

        def generic_find(remote, service_id, type, ref)
          # find_application criteria only accepts one parameter.
          # Otherwise unexpected behavior
          attrs = remote.find_application(service_id: service_id, type => ref)
          if (errors = attrs['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Application find error', errors)
          end

          new(id: attrs.fetch('id'), remote: remote, attrs: attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end
      end

      attr_reader :id, :remote

      def initialize(id:, remote:, attrs: nil)
        @id = id.to_i
        @remote = remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= application_attrs
      end

      def update(app_attrs)
        new_attrs = remote.update_application(account_id, id, app_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Application has not been updated', errors)
        end

        @attrs = new_attrs

        new_attrs
      end

      def resume
        return attrs if live?

        new_attrs = remote.resume_application(account_id, id)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Application has not been resumed', errors)
        end

        @attrs = new_attrs

        new_attrs
      end

      def suspend
        return attrs unless live?

        new_attrs = remote.suspend_application(account_id, id)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Application has not been suspended', errors)
        end

        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_application account_id, id
      end

      def live?
        attrs.fetch('state') == 'live'
      end

      private

      def account_id
        attrs.fetch('account_id')
      end

      def application_attrs
        remote.show_application(id).tap do |application|
          if (errors = application['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Application attrs not read', errors)
          end
        end
      end
    end
  end
end
