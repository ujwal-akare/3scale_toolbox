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

        # ref can be
        # * Email of the account user.
        # * Username of the account user.
        # * ID of the account user.
        # * [Master API] Provider key of the account
        # * [Master API] Service token of the account service.
        #
        # email, username or user_id fields search with AND logic. Therefore separate requests.
        # buyer_provider_key, buyer_service_token fields search with OR logic. Same request.
        def find_by_text(ref, remote)
          account = find_by_email(remote, ref)
          return account unless account.nil?

          account = find_by_username(remote, ref)
          return account unless account.nil?

          account = find_by_user_id(remote, ref)
          return account unless account.nil?

          account = find_by_provider_or_service_token(remote, ref)
          return account unless account.nil?

          nil
        end

        def find_by_email(remote, email)
          generic_find(remote, email: email)
        end

        def find_by_username(remote, username)
          generic_find(remote, username: username)
        end

        def find_by_user_id(remote, user_id)
          generic_find(remote, user_id: user_id)
        end

        def find_by_provider_or_service_token(remote, text)
          generic_find(remote, buyer_provider_key: text, buyer_service_token: text)
        end

        def generic_find(remote, criteria)
          account = remote.find_account(**criteria)
          if (errors = account['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new(
              'Account find returned errors', errors
            )
          end
          new(id: account['id'], remote: remote, attrs: account)
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
