module ThreeScaleToolbox
  module Tasks
    module CopyTask
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end

      attr_reader :source, :target

      def initialize(source:, target:)
        @source = source
        @target = target
      end
    end
  end
end
