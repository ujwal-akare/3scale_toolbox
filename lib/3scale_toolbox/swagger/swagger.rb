require 'json-schema'

module ThreeScaleToolbox
  module Swagger
    META_SCHEMA_PATH = File.expand_path('../../../resources/swagger_meta_schema.json', __dir__)

    def self.build(raw_specification, validate: true)
      if validate
        meta_schema = JSON.parse(File.read(META_SCHEMA_PATH))
        JSON::Validator.validate!(meta_schema, raw_specification)
      end

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

    class SecurityRequirement
      attr_reader :id, :type, :name, :in_f, :flow, :scopes

      def initialize(id:, type:, name: nil, in_f: nil, flow: nil, scopes: [])
        @id = id
        @type = type
        @name = name
        @in_f = in_f
        @flow = flow
        @scopes = scopes
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

      def host
        raw['host']
      end

      def schemes
        raw['schemes']
      end

      def info
        @info ||= parse_info(raw['info'])
      end

      def operations
        @operations ||= parse_operations
      end

      def global_security_requirements
        @global_security_requirements ||= parse_global_security_reqs
      end

      private

      def parse_operations
        raw['paths'].flat_map do |path, path_obj|
          path_obj.flat_map do |method, operation|
            next unless %w[get head post put patch delete trace options].include? method

            Operation.new(verb: method, path: path, operation_id: operation['operationId'])
          end.compact
        end
      end

      def parse_info(info)
        Info.new(title: info['title'], description: info['description'])
      end

      def parse_global_security_reqs
        security_requirements.flat_map do |sec_req|
          sec_req.map do |sec_item_name, sec_item|
            sec_def = fetch_security_definition(sec_item_name)
            SecurityRequirement.new(id: sec_item_name, type: sec_def['type'],
                                    name: sec_def['name'], in_f: sec_def['in'],
                                    flow: sec_def['flow'], scopes: sec_item)
          end
        end
      end

      def fetch_security_definition(name)
        security_definitions.fetch(name) do |el|
          raise ThreeScaleToolbox::Error, "Swagger parsing error: #{el} not found in security definitions"
        end
      end

      def security_requirements
        raw['security'] || []
      end

      def security_definitions
        raw['securityDefinitions'] || {}
      end
    end
  end
end
