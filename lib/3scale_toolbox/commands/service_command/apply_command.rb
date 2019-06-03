module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module Apply
        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply <remote> <service-id_or_system-name>'
              summary     'Update service'
              description "Update (create if it does not exist) service"
              runner ApplySubcommand

              param   :remote
              param   :service_id_or_system_name

              option :d, :'deployment-mode', "Specify the deployment mode of the service", argument: :required
              option :n, :name, "Specify the name of the metric", argument: :required
              option :a, :'authentication-mode', "Specify authentication mode of the service ('1' for API key, '2' for App Id / App Key, 'oauth' for OAuth mode, 'oidc' for OpenID Connect)", argument: :required
              option nil, :description, "Specify the description of the service", argument: :required
              option nil, :'support-email', "Specify the support email of the service", argument: :required
            end
          end

          def run
            res = service
            if res.nil?
              res = Entities::Service.create(remote: remote, service_params: create_service_attrs)
            else
              res.update(service_attrs) unless service_attrs.empty?
            end

            output_msg_array = ["Applied Service id: #{res.id}"]
            puts output_msg_array
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def ref
            @ref ||= arguments[:service_id_or_system_name]
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service::find(remote: remote, ref: ref)
          end

          def service_attrs
            {
              "deployment_option" => options[:'deployment-mode'],
              "backend_version" => options[:'authentication-mode'],
              "description" => options[:description],
              "support_email" => options[:'support-email'],
              "name" => options[:name],
            }.compact
          end

          def create_service_attrs
            service_attrs.merge(
              "system_name" => ref,
              "name" => ref
            ) { |_key, oldval, _newval| oldval } # receiver of the merge message has key priority
          end
        end
      end
    end
  end
end
