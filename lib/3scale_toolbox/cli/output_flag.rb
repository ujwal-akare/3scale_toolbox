module ThreeScaleToolbox
  module CLI
    class PrinterTransformer
      def call(output_format)
        raise unless %w[yaml json].include?(output_format)

        case output_format
        when 'yaml'
          YamlPrinter.new
        when 'json'
          JsonPrinter.new
        end
      end
    end

    def self.output_flag(dsl)
      dsl.option :o, :output, 'Output format. One of: json|yaml', argument: :required, transform: PrinterTransformer.new
    end
  end
end
