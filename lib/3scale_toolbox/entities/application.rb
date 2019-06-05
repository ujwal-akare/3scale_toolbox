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
