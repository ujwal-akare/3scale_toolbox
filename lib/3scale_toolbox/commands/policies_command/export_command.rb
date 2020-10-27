module ThreeScaleToolbox
  module Commands
    module PoliciesCommand
      class ExportSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        class JSONSerializer
          def call(object)
            JSON.pretty_generate(object)
          end
        end

        class YAMLSerializer
          def call(object)
            YAML.dump(object)
          end
        end

        class SerializerTransformer
          def call(output_format)
            raise unless %w[yaml json].include?(output_format)

            case output_format
            when 'yaml'
              YAMLSerializer.new
            when 'json'
              JSONSerializer.new
            end
          end
        end

        def self.command
          Cri::Command.define do
            name        'export'
            usage       'export [opts] <remote> <product>'
            summary     'export product policy chain'
            description 'export product policy chain'

            option      :f, :file, 'Write to file instead of stdout', argument: :required
            option      :o, :output, 'Output format. One of: json|yaml', argument: :required, transform: SerializerTransformer.new
            param       :remote
            param       :service_ref

            runner ExportSubcommand
          end
        end

        def run
          select_output do |output|
            output.write(serializer.call(product.policies))
          end
        end

        private

        def remote
          @remote ||= threescale_client(arguments[:remote])
        end

        def product
          @product ||= find_product
        end

        def service_ref
          arguments[:service_ref]
        end

        def find_product
          Entities::Service.find(remote: remote,
                                 ref: service_ref).tap do |svc|
            raise ThreeScaleToolbox::Error, "Product #{service_ref} does not exist" if svc.nil?
          end
        end

        def file
          options[:file]
        end

        def select_output
          ios = if file
                  File.open(file, 'w')
                else
                  $stdout
                end
          begin
            yield(ios)
          ensure
            ios.close
          end
        end

        def serializer
          options.fetch(:output, YAMLSerializer.new)
        end
      end
    end
  end
end
