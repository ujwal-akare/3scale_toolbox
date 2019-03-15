require 'json-schema'

module ThreeScaleToolbox
  module Swagger
    META_SCHEMA_PATH = File.expand_path('../../../resources/swagger_meta_schema.json', __dir__)

    def self.build(raw_specification)
      meta_schema = JSON.parse(File.read(META_SCHEMA_PATH))
      JSON::Validator.validate!(meta_schema, raw_specification)

      Specification.new(raw_specification)
    end

    class Info
      attr_reader :title, :description

      def initialize(title:, description:)
        @title = title
        @description = description
      end
    end

    class Operation
      attr_reader :verb, :operation_id, :path

      def initialize(verb:, operation_id:, path:)
        @verb = verb
        @operation_id = operation_id
        @path = path
      end
    end

    class Specification
      attr_reader :raw

      def initialize(raw_resource)
        @raw = raw_resource
      end

      def base_path
        raw['basePath']
      end

      def info
        @info ||= parse_info(raw['info'])
      end

      def operations
        @operations ||= parse_operations
      end

      private

      def parse_operations
        raw['paths'].flat_map do |path, path_obj|
          path_obj.flat_map do |method, operation|
            Operation.new(verb: method, path: path, operation_id: operation['operationId'])
          end
        end
      end

      def parse_info(info)
        Info.new(title: info['title'], description: info['description'])
      end
    end
  end
end
