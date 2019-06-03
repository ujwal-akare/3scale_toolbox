require '3scale_toolbox/entities/base_entity'

module ThreeScaleToolbox
  module Entities
    class Account
      include ThreeScaleToolbox::Entities::Entity
      PRINTABLE_VARS = %w[
        id org_name
      ].freeze
      VERBOSE_PRINTABLE_VARS = %w[
        id org_name created_at updated_at admin_domain domain from_email
        support_email finance_support_email monthly_billing_enabled
        monthly_charging_enabled
      ].freeze
      public_constant :PRINTABLE_VARS
      public_constant :VERBOSE_PRINTABLE_VARS

      def self.find(text, client)
        account = client.find_account(email: text, buyer_provider_key: text,
                                      buyer_service_token: text)
        if (errors = account['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new(
            'Account find returned errors', errors
          )
        end
        account_id = account['id']
        self.new(id: account_id, attrs: account)
      end
    end
  end
end
