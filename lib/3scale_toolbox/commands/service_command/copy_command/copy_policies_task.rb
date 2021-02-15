module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyPoliciesTask
          include Task

          def call
            logger.info 'copy proxy policies'
            source_policies = source.policies
            target.update_policies('policies_config' => source_policies)
          end
        end
      end
    end
  end
end
