module ThreeScaleToolbox
  module CLI
    class JsonPrinter
      def print_record(record)
        puts JSON.pretty_generate(record)
      end

      def print_collection(collection)
        puts JSON.pretty_generate(collection)
      end
    end
  end
end
