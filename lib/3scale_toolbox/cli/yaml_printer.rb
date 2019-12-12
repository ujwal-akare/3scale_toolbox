module ThreeScaleToolbox
  module CLI
    class YamlPrinter
      def print_record(record)
        puts YAML.dump(record)
      end

      def print_collection(collection)
        puts YAML.dump(collection)
      end
    end
  end
end
