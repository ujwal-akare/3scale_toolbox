module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class ExportSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'export'
            usage       'export [opts] <remote> <product>'
            summary     'Export product to serialized format'
            description 'This command serializes the referenced product and associated backends into a yaml format'

            option      :f, :file, 'Write to file instead of stdout', argument: :required
            param       :remote
            param       :product_ref

            runner ExportSubcommand
          end
        end

        def run
          select_output do |output|
            output.write(serialized_object.to_yaml)
          end
        end

        private

        def remote
          @remote ||= threescale_client(arguments[:remote])
        end

        def serialized_object
          {
            'apiVersion' => 'v1',
            'kind' => 'List',
            'items' => [product.to_crd] + backends.map(&:to_crd)
          }
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

        def product
          @product ||= find_product
        end

        def backends
          product.backend_usage_list.map do |backend_usage|
            Entities::Backend.new(id: backend_usage.backend_id, remote: remote)
          end
        end

        def product_ref
          arguments[:product_ref]
        end

        def find_product
          Entities::Service.find(remote: remote, ref: product_ref).tap do |prd|
            raise ThreeScaleToolbox::Error, "Product #{product_ref} does not exist" if prd.nil?
          end
        end

        def file
          options[:file]
        end
      end
    end
  end
end
