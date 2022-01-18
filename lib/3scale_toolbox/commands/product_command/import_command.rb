module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class ImportSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::ResourceReader

        def self.command
          Cri::Command.define do
            name        'import'
            usage       'import [opts] <remote>'
            summary     'Import product from serialized format'
            description 'This command deserializes one product and associated backends'

            option      :f, :file, 'Read from file instead of stdin', argument: :required
            ThreeScaleToolbox::CLI.output_flag(self)
            param       :remote

            runner ImportSubcommand
          end
        end

        def run
          validate_artifacts_resource!

          product_list.each do |product|
            context = {
                target_remote: remote,
                source_remote: crd_remote,
                source_service_ref: product.system_name,
                delete_mapping_rules: true,
                logger: Logger.new(File::NULL)
            }

            Commands::ProductCommand::CopySubcommand.workflow(context)

            report[product.system_name] = context.fetch(:report)
          end

          printer.print_collection report
        end

        private

        def crd_remote
          @crd_remote ||= CRD::Remote.new(product_list, backend_list)
        end

        def product_list
          @product_list ||= product_resources.map do |product_cr|
            CRD::ProductParser.new product_cr
          end
        end

        def backend_list
          @backend_list ||= backend_resources.map do |backend_cr|
            CRD::BackendParser.new backend_cr
          end
        end

        def validate_artifacts_resource!
          # TODO: Add openapiV3 validation
          # https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/deploy/crds/capabilities.3scale.net_backends_crd.yaml
          # https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/deploy/crds/capabilities.3scale.net_products_crd.yaml
          validate_api_version!

          validate_kind!
        end

        def validate_api_version!
          artifacts_resource.fetch('apiVersion') do
            raise ThreeScaleToolbox::Error, 'Invalid content. apiVersion not found'
          end

          raise ThreeScaleToolbox::Error, 'Invalid content. apiVersion wrong value ' unless artifacts_resource.fetch('apiVersion') == 'v1'
        end

        def validate_kind!
          artifacts_resource.fetch('kind') do
            raise ThreeScaleToolbox::Error, 'Invalid content. kind not found'
          end

          raise ThreeScaleToolbox::Error, 'Invalid content. kind wrong value ' unless artifacts_resource.fetch('kind') == 'List'
        end

        def artifacts_resource_items
          artifacts_resource.fetch('items') do
            raise ThreeScaleToolbox::Error, 'Invalid content. items not found'
          end
        end

        def product_resources
          artifacts_resource_items.select do |item|
            item.respond_to?(:has_key?) &&
              item.fetch('apiVersion', '').include?('capabilities.3scale.net') &&
              item['kind'] == 'Product'
          end
        end

        def backend_resources
          artifacts_resource_items.select do |item|
            item.respond_to?(:has_key?) &&
              item.fetch('apiVersion', '').include?('capabilities.3scale.net') &&
              item['kind'] == 'Backend'
          end
        end

        def artifacts_resource
          @artifacts_resource ||= load_resource(options[:file] || '-', verify_ssl)
        end

        def report
          @report ||= {}
        end

        def remote
          @remote ||= threescale_client(arguments[:remote])
        end

        def printer
          options.fetch(:output, CLI::JsonPrinter.new)
        end
      end
    end
  end
end
