module ThreeScaleToolbox
  module Tasks
    module CopyTask
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      attr_reader :source_service, :copy_service

      def initialize(source_service:, copy_service:)
        @source_service = source_service
        @copy_service = copy_service
      end
    end
  end
end
