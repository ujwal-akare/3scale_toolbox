module ThreeScaleToolbox
  module Commands
    module ImportCommand
      module OpenAPI
        module ResourceReader
          ##
          # Reads resources from different types of sources.
          # Supported types are: file, URL, stdin
          # Return type is
          # [content, format] where
          # content: raw content
          # format: Hash with single key: `format`. Value can be `:json` or `:yaml`
          # format example: { format: :json }
          def openapi_resource(resource)
            case resource
            when '-'
              method(:read_stdin)
            when /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
              method(:read_url)
            else
              method(:read_file)
            end.call(resource)
          end

          # Detect format from file extension
          def read_file(resource)
            [File.read(resource), { format: File.extname(resource) }]
          end

          def read_stdin(_resource)
            content = STDIN.read
            # will try parse json, otherwise yaml
            format = :json
            begin
              JSON.parse(content)
            rescue JSON::ParserError
              format = :yaml
            end
            [content, { format: format }]
          end

          def read_url(resource)
            uri = URI.parse(resource)
            [Net::HTTP.get(uri), { format: File.extname(uri.path) }]
          end
        end
      end
    end
  end
end
