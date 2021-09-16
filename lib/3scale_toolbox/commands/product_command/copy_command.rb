require '3scale_toolbox/commands/product_command/copy_command/delete_target_backend_usages_task'
require '3scale_toolbox/commands/product_command/copy_command/copy_backends_task'

module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class CopySubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'copy'
            usage       'copy [opts] -s <source-remote> -d <target-remote> <source-product>'
            summary     'Copy product'
            description <<-HEREDOC
            This command makes a copy of the referenced product.
            Target product will be searched by the source product system name. System name can be overridden with `--target-system-name` option.
            If a product with the selected `system_name` is not found, it will be created.
            \n Components of the product being copied:
            \nproduct configuration
            \nproduct settings
            \nproduct methods&metrics: Only missing metrics&methods will be created.
            \nproduct mapping rules: mapping rules will be replaced. Existing mapping rules will be removed.
            \nproduct application plans & pricing rules & limits: Only missing application plans & pricing rules & limits will be created.
            \nproduct application usage rules
            \nproduct policies
            \nproduct backends: Only missing backends will be created.
            \nproduct activedocs: Only missing activedocs will be created.
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target-system-name', 'Target system name. Default to source system name', argument: :required
            param   :source_product

            runner CopySubcommand
          end
        end

        def self.workflow(context)
          tasks = []
          tasks << ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CreateOrUpdateTargetServiceTask.new(context)
          tasks << CopyCommand::DeleteExistingTargetBackendUsagesTask.new(context)
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

        def run
          self.class.workflow(context)
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
            delete_mapping_rules: true,
            option_target_system_name: options[:'target-system-name']
          }
        end
      end
    end
  end
end
