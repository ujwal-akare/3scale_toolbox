module ThreeScaleToolbox
  module Tasks
    class CopyPoliciesTask
      include CopyTask

      def call
        puts 'copy proxy policies'
        source_policies = source.policies
        target.update_policies('policies_config' => source_policies)
      end
    end
  end
end
