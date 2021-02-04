module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class ReadProductStep
        include Step

        ##
        # Reads product attrs
        def call
          result[:product] = {}
        end
      end
    end
  end
end
