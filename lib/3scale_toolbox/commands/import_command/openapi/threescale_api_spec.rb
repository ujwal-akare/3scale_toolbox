module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        class ThreeScaleApiSpec
          class << self
            def parse(openapi)
              parser = Parser.new
              parse_operations_method = method(:parse_operations)
              parser.on(:title) { openapi.info.title }
              parser.on(:description) { openapi.info.description }
              parser.on(:operations) { parse_operations_method.call(openapi) }
              new(parser)
            end

            private

            def parse_operations(openapi)
              openapi.operations.map do |op|
                Operation.new(
                  path: "#{openapi.base_path}#{op.path}",
                  verb: op.verb,
                  operationId: op.operationId
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
