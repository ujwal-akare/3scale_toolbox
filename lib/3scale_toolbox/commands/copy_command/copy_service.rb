require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module CopyCommand
      class CopyServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <service_id>'
            summary     'copy service'
            description 'will create a new services, copy existing proxy settings, metrics, methods, application plans and mapping rules.'

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name. Default to source system name', argument: :required
            param   :service_id

            runner CopyServiceSubcommand
          end
        end

        def run
          source      = fetch_required_option(:source)
          destination = fetch_required_option(:destination)

          source_service = Entities::Service.new(id: arguments[:service_id],
                                                 remote: threescale_client(source))
          target_service = create_new_service(source_service.show_service, destination)
          puts "new service id #{target_service.id}"
          context = create_context(source_service, target_service)
          tasks = [
            Tasks::CopyServiceProxyTask.new(context),
            Tasks::CopyMethodsTask.new(context),
            Tasks::CopyMetricsTask.new(context),
            Tasks::CopyApplicationPlansTask.new(context),
            Tasks::CopyLimitsTask.new(context),
            Tasks::DestroyMappingRulesTask.new(context),
            Tasks::CopyMappingRulesTask.new(context)
          ]
          tasks.each(&:call)
        end

        private

        def create_context(source, target)
          {
            source: source,
            target: target
          }
        end

        def create_new_service(service, destination)
          Entities::Service.create(remote: threescale_client(destination),
                                   service: service,
                                   system_name: options[:target_system_name] || service['system_name'])
        end
      end
    end
  end
end
