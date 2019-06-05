module ThreeScaleToolbox
  module Entities
    class Application
      class << self
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
