require '3scale_toolbox/commands/update_command/service_command/delete_activedocs_task'
require '3scale_toolbox/commands/update_command/service_command/copy_service_settings_task'

module ThreeScaleToolbox
  module Commands
    module UpdateCommand
      class ServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <src_service_id> <dst_service_id>'
            summary     '[DEPRECATED] update service'
            description <<-HEREDOC
            This command has been deprecated. Use '3scale service copy' instead.
            \n Update existing service, update proxy settings, metrics, methods, application plans and mapping rules.'
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name', argument: :required
            flag    :f, :force, 'Overwrites the mapping rules by deleting all rules from target service first'
            flag    :r, 'rules-only', 'Updates only the mapping rules'
            param   :src_service_id
            param   :dst_service_id

            runner ServiceSubcommand
          end
        end

        def run
          warn "\e[1m\e[31mThis command has been deprecated. Use '3scale service copy' instead\e[0m"
          source_service = Entities::Service.new(
            id: arguments[:src_service_id],
            remote: threescale_client(fetch_required_option(:source))
          )
          update_service = Entities::Service.new(
            id: arguments[:dst_service_id],
            remote: threescale_client(fetch_required_option(:destination))
          )
          context = create_context(source_service, update_service)

          tasks = []
          unless options[:'rules-only']
            tasks << ServiceCommand::CopyServiceSettingsTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMethodsTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyApplicationPlansTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyLimitsTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPoliciesTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPricingRulesTask.new(context)
            tasks << ServiceCommand::DeleteActiveDocsTask.new(context)
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyActiveDocsTask.new(context)
            # Copy proxy must be the last task
            # Proxy update is the mechanism to increase version of the proxy,
            # Hence propagating (mapping rules, poicies, oidc, auth) update to
            # latest proxy config, making available to gateway.
            tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyServiceProxyTask.new(context)
          end
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask.new(context)

          # run tasks
          tasks.each(&:call)
        end

        private

        def create_context(source, target)
          {
            source: source,
            target: target,
            delete_mapping_rules: options[:force]
          }
        end
      end
    end
  end
end
