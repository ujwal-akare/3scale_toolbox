require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module CopyCommand
      class CopyServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::Remotes

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <service_id>'
            summary     'Copy service'
            description 'Will create a new services, copy existing proxy settings, metrics, methods, application plans and mapping rules.'

            option  :s, :source, '3scale source instance. Format: "http[s]://<provider_key>@3scale_url"', argument: :required
            option  :d, :destination, '3scale target instance. Format: "http[s]://<provider_key>@3scale_url"', argument: :required
            option  :t, 'target_system_name', 'Target system name', argument: :required
            param   :service_id

            runner CopyServiceSubcommand
          end
        end

        def run
          source      = fetch_required_option(:source)
          destination = fetch_required_option(:destination)
          system_name = fetch_required_option(:target_system_name)

          copy_service(arguments[:service_id], source, destination, system_name)
        end

        private

        def create_context(source_service, copy_service)
          {
            source_service: source_service,
            copy_service: copy_service
          }
        end

        def create_new_service(service, destination, system_name)
          Entities::Service.create(remote: remote(destination),
                                   service: service,
                                   system_name: system_name)
        end

        def copy_service(service_id, source, destination, system_name)
          source_service = Entities::Service.new(id: service_id, remote: remote(source))
          copy_service = create_new_service(source_service.show_service, destination, system_name)
          context = create_context(source_service, copy_service)
          tasks = [Tasks::CopyServiceProxyTask, Tasks::CopyMetricsTask, Tasks::CopyMethodsTask,
                   Tasks::CopyApplicationPlansTask, Tasks::CopyLimitsTask,
                   Tasks::DestroyMappingRulesTask, Tasks::CopyMappingRulesTask]
          tasks.each do |task_class|
            task_class.call(context)
          end
        end
      end
    end
  end
end
