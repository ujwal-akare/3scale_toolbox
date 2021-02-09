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
            param       :remote

            runner ImportSubcommand
          end
        end

        def run
          validate_artifacts_resource!

          backend_resources.each do |cr|
            Entities::Backend.from_cr(remote: remote, cr: cr)
          end
          product_resources.each do |cr|
            Entities::Service.from_cr(remote: remote, cr: cr)
          end
        end

        private

        def validate_artifacts_resource!
          validate_api_version!

          validate_kind!

          validate_items!
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

        def validate_items!
          artifacts_resource.fetch('items') do
            raise ThreeScaleToolbox::Error, 'Invalid content. items not found'
          end

          raise ThreeScaleToolbox::Error, 'Invalid content. items not a list' unless artifacts_resource.fetch('items').respond_to?(:each)
        end

        def artifacts_resource_items
          artifacts_resource.fetch('items')
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
          @artifacts_resource ||= load_resource(options[:file] || '-')
        end

        def remote
          @remote ||= threescale_client(arguments[:remote])
        end
      end
    end
  end
end
