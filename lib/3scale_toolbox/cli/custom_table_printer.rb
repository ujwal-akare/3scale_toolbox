module ThreeScaleToolbox
  module CLI
    class CustomTablePrinter
      attr_reader :fields

      def initialize(fields)
        @fields = fields
      end

      def print_record(record)
        print_collection([record])
      end

      def print_collection(collection)
        print_header
        print_data(collection)
      end

      private

      def print_header
        puts fields.map(&:upcase).join("\t")
      end

      def print_data(collection)
        collection.each do |obj|
          puts fields.map { |field| obj.fetch(field, '(empty)').to_s }.join("\t")
        end
      end
    end
  end
end
