module ThreeScaleToolbox
  module Commands
    module ProductCommand
      module Step
        attr_reader :context

        def initialize(context)
          @context = context
        end

        def file
          context[:file]
        end

        def threescale_client
          context[:threescale_client]
        end

        def result
          context[:result] ||= {}
        end
      end
    end
  end
end
