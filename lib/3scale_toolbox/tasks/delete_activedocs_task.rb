module ThreeScaleToolbox
  module Tasks
    class DeleteActiveDocsTask
      attr_reader :context

      def initialize(context)
        @context = context
      end

      def call
        puts 'deleting all target service ActiveDocs'
        target.list_activedocs.each do |activedoc|
          target.remote.delete_activedocs(activedoc['id'])
        end
      end

      def target
        context[:target]
      end
    end
  end
end
