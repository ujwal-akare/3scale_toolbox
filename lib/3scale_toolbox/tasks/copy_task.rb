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

      def source_metrics
        context[:source_metrics] ||= source.metrics
      end

      def source_hits
        context[:source_hits] ||= source.hits
      end

      def source_methods
        context[:source_methods] ||= source.methods(source_hits.fetch('id'))
      end

      def source_metrics_and_methods
        source_metrics + source_methods
      end

      def target_metrics
        context[:target_metrics] ||= target.metrics
      end

      def target_hits
        context[:target_hits] ||= target.hits
      end

      def target_methods
        context[:target_methods] ||= target.methods(target_hits.fetch('id'))
      end

      def target_metrics_and_methods
        target_metrics + target_methods
      end

      def invalidate_target_methods
        context[:target_methods] = nil
      end

      def invalidate_target_metrics
        context[:target_metrics] = nil
      end
    end
  end
end
