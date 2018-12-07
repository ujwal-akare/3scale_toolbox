module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ThreeScaleApiSpec
          class << self
            def parse(openapi)
              parser = Parser.new
              spec = self
              parser.on(:title) { spec.parse_title(openapi) }
              parser.on(:description) { spec.parse_description(openapi) }
              parser.on(:operations) { spec.parse_operations(openapi) }
              new(parser)
            end

            def parse_title(openapi)
              openapi.info.title
            end

            def parse_description(openapi)
              openapi.info.description
            end

            def parse_operations(openapi)
              openapi.operations.map do |op|
                Operation.new(
                  path: "#{openapi.base_path}#{op.path}",
                  verb: op.verb
                )
              end
            end
          end

          class Parser
            def initialize
              @callbacks = {}
            end

            def each(&block)
              callbacks.each(&block)
            end

            def on(attribute, &block)
              callbacks[attribute.to_sym] = block
            end

            private

            attr_reader :callbacks
          end

          def initialize(parser)
            parser.each do |attribute, callback|
              self.class.send(:define_method, attribute, &callback)
            end
          end
        end
      end
    end
  end
end
