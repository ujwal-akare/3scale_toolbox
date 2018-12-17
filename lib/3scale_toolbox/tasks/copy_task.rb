module ThreeScaleToolbox
  module Tasks
    module CopyTask
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      attr_reader :context

      def initialize(context)
        @context = context
      end

      def source
        context[:source]
      end

      def target
        context[:target]
      end
    end
  end
end
