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
        # * Application internal id
        # * User_key (API key)
        # * App_id (from app_id/app_key pair)
        # * Client ID (for OAuth and OpenID Connect authentication modes)
        def find(remote:, ref:)
          attrs = remote.find_application(id: ref, user_key: ref, application_id: ref)
          new(id: ref, remote: remote, attrs: attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end
      end

      attr_reader :id, :remote

      def initialize(id:, remote:, attrs: nil)
        @id = id
        @remote = remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= application_attrs
      end

      private

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
