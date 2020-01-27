require '3scale_toolbox/commands/product_command/copy_command/copy_backends_task'

module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class CopySubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'copy'
            usage       'copy [opts] -s <source_remote> -d <target_remote> <source_product>'
            summary     'Copy product'
            description <<-HEREDOC
            This command makes a copy of the referenced product.
            Target product will be searched by source product system name. System name can be overriden with `--target_system_name` option.
            If a product with the selected `system_name` is not found, it will be created.
            \n Components of the product being copied:
            \nproduct configuration
            \nproduct settings
            \nproduct methods&metrics
            \nproduct mapping rules
            \nproduct application plans & pricing rules & limits
            \nproduct application usage rules
            \nproduct policies
            \nproduct backends
            \nproduct activedocs
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name. Default to source system name', argument: :required
            param   :source_product

            runner CopySubcommand
          end
        end

        def run
          tasks = []
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CreateOrUpdateTargetServiceTask.new(context)
          tasks << CopyCommand::CopyBackendsTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyServiceProxyTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMethodsTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMetricsTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMappingRulesTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyApplicationPlansTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyLimitsTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPoliciesTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyPricingRulesTask.new(context)
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyActiveDocsTask.new(context)
          tasks.each(&:call)

          # This should be the last step
          ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::BumpProxyVersionTask.new(service: context[:target]).call
        end

        private

        def context
          @context ||= create_context
        end

        def create_context
          {
            source_remote: threescale_client(fetch_required_option(:source)),
            target_remote: threescale_client(fetch_required_option(:destination)),
            source_service_ref: arguments[:source_product],
            option_target_system_name: options[:target_system_name]
          }
        end
      end
    end
  end
end
