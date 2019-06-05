module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module Create
        class CreateSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'create'
              usage       'create [options] <remote> <service-name>'
              summary     'Create a service'
              description 'Create a service'
              runner CreateSubcommand

              param   :remote
              param   :service_name

              option :d, :'deployment-mode', "Specify the deployment mode of the service", argument: :required
              option :s, :'system-name', "Specify the system-name of the service", argument: :required
              option :a, :'authentication-mode', "Specify authentication mode of the service ('1' for API key, '2' for App Id / App Key, 'oauth' for OAuth mode, 'oidc' for OpenID Connect)", argument: :required
              option nil, :description, "Specify the description of the service", argument: :required
              option nil, :'support-email', "Specify the support email of the service", argument: :required
            end
          end

          def run
            create_service_params = service_attrs
            result = Entities::Service.create(remote: remote, service_params: create_service_params)
            puts "Service '#{arguments[:service_name]}' has been created with ID: #{result.id}"
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def parse_options
            {
              "deployment_option" => options[:'deployment-mode'],
              "system_name" => options[:'system-name'],
              "backend_version" => options[:'authentication-mode'],
              "description" => options[:description],
              "support_email" => options[:'support-email'],
            }.compact
          end

          def service_attrs
            service_name = arguments[:service_name]
            create_service_attrs = parse_options
            create_service_attrs["name"] = service_name
            create_service_attrs
          end
        end
      end
    end
  end
end
