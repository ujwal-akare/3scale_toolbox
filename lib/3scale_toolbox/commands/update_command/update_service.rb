require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module UpdateCommand
      class UpdateServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <src_service_id> <dst_service_id>'
            summary     'update service'
            description 'Update existing service, update proxy settings, metrics, methods, application plans and mapping rules.'

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name', argument: :required
            flag    :f, :force, 'Overwrites the mapping rules by deleting all rules from target service first'
            flag    :r, 'rules-only', 'Updates only the mapping rules'
            param   :src_service_id
            param   :dst_service_id

            runner UpdateServiceSubcommand
          end
        end

        def run
          source_service = Entities::Service.new(
            id: arguments[:src_service_id],
            remote: threescale_client(fetch_required_option(:source))
          )
          update_service = Entities::Service.new(
            id: arguments[:dst_service_id],
            remote: threescale_client(fetch_required_option(:destination))
          )
          system_name = options[:target_system_name]
          context = create_context(source_service, update_service)

          tasks = []
          unless options[:'rules-only']
            tasks << Tasks::UpdateServiceSettingsTask.new(context.merge(target_name: system_name))
            tasks << Tasks::CopyServiceProxyTask.new(context)
            tasks << Tasks::CopyMethodsTask.new(context)
            tasks << Tasks::CopyMetricsTask.new(context)
            tasks << Tasks::CopyApplicationPlansTask.new(context)
            tasks << Tasks::CopyLimitsTask.new(context)
          end
          tasks << Tasks::DestroyMappingRulesTask.new(context) if options[:force]
          tasks << Tasks::CopyMappingRulesTask.new(context)

          # run tasks
          tasks.each(&:call)
        end

        private

        def create_context(source, target)
          {
            source: source,
            target: target
          }
        end
      end
    end
  end
end
