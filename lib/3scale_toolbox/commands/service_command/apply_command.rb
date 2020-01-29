module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module Apply
        class CustomPrinter
          attr_reader :option_default, :option_disabled

          def print_record(service)
            puts "Applied Service id: #{service['id']}"
          end

          def print_collection(collection) end
        end

        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply <remote> <service-id_or_system-name>'
              summary     'Update service'
              description "Update (create if it does not exist) service"

              param   :remote
              param   :service_id_or_system_name

              ThreeScaleToolbox::CLI.output_flag(self)
              option :d, :'deployment-mode', "Specify the deployment mode of the service", argument: :required
              option :n, :name, "Specify the name of the metric", argument: :required
              option :a, :'authentication-mode', "Specify authentication mode of the service ('1' for API key, '2' for App Id / App Key, 'oauth' for OAuth mode, 'oidc' for OpenID Connect)", argument: :required
              option nil, :description, "Specify the description of the service", argument: :required
              option nil, :'support-email', "Specify the support email of the service", argument: :required

              runner ApplySubcommand
            end
          end

          def run
            service = Entities::Service.find(remote: remote, ref: ref)
            if service.nil?
              service = Entities::Service.create(remote: remote,
                                                 service_params: create_attrs)
            else
              service.update(update_attrs) unless update_attrs.empty?
            end

            printer.print_record service.attrs
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def ref
            @ref ||= arguments[:service_id_or_system_name]
          end

          def base_service_attrs
            {
              "deployment_option" => options[:'deployment-mode'],
              "backend_version" => options[:'authentication-mode'],
              "description" => options[:description],
              "support_email" => options[:'support-email'],
              "name" => options[:name],
            }.compact
          end

          def update_attrs
            base_service_attrs
          end

          def create_attrs
            base_service_attrs.merge(
              "system_name" => ref,
              "name" => ref
            ) { |_key, oldval, _newval| oldval } # receiver of the merge message has key priority
          end

          def printer
            # keep backwards compatibility
            options.fetch(:output, CustomPrinter.new)
          end
        end
      end
    end
  end
end
