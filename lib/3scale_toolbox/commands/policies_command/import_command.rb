module ThreeScaleToolbox
  module Commands
    module PoliciesCommand
      class ImportSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::ResourceReader

        def self.command
          Cri::Command.define do
            name        'import'
            usage       'import [opts] <remote> <product>'
            summary     'import product policy chain'
            description 'import product policy chain'

            option      :f, :file, 'Read from file', argument: :required
            option      :u, :url, 'Read from url', argument: :required
            param       :remote
            param       :service_ref

            runner ImportSubcommand
          end
        end

        def run
          res = product.update_policies('policies_config' => policies)
          if res.is_a?(Hash) && (errors = res['errors'])
            raise ThreeScaleToolbox::Error, "Product policies have not been imported. #{errors}"
          end
          if res.is_a?(Array) && (error_item = res.find { |i| i.key?('errors') })
            raise ThreeScaleToolbox::Error, "Product policies have not been imported. #{error_item['errors']}"
          end
        end

        private

        def remote
          @remote ||= threescale_client(arguments[:remote])
        end

        def service_ref
          arguments[:service_ref]
        end

        def product
          @product ||= find_product
        end

        def find_product
          Entities::Service.find(remote: remote,
                                 ref: service_ref).tap do |svc|
            raise ThreeScaleToolbox::Error, "Product #{service_ref} does not exist" if svc.nil?
          end
        end

        def policies
          @policies ||= load_resource(options[:file] || options[:url] || '-')
        end
      end
    end
  end
end
