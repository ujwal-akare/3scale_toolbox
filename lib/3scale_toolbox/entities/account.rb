require '3scale_toolbox/entities/base_entity'

module ThreeScaleToolbox
  module Entities
    class Account
      include ThreeScaleToolbox::Entities::Entity
      PRINTABLE_VARS = %w[id org_name].freeze
      VERBOSE_PRINTABLE_VARS = %w[
        id org_name created_at updated_at admin_domain domain from_email
        support_email finance_support_email monthly_billing_enabled
        monthly_charging_enabled
      ].freeze
      public_constant :PRINTABLE_VARS
      public_constant :VERBOSE_PRINTABLE_VARS

      class << self
        def find(remote:, ref:)
          new(id: ref, remote: remote).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_text(ref, remote)
        end

        def find_by_text(text, client)
          account = client.find_account(email: text, buyer_provider_key: text,
                                        buyer_service_token: text)
          if (errors = account['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new(
              'Account find returned errors', errors
            )
          end
          new(id: account['id'], remote: client, attrs: account)
        rescue ThreeScale::API::HttpClient::NotFoundError
          nil
        end
      end

      def attrs
        @attrs ||= account_attrs
      end

      def applications
        app_attrs_list = remote.list_account_applications(id)
        if app_attrs_list.respond_to?(:has_key?) && (errors = app_attrs_list['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Account applications not read', errors)
        end

        app_attrs_list.map do |app_attrs|
          Entities::Application.new(id: app_attrs.fetch('id'), remote: remote, attrs: app_attrs)
        end
      end

      private

      def account_attrs
        remote.show_account(id).tap do |account|
          if (errors = account['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Account attrs not read', errors)
          end
        end
      end
    end
  end
end
