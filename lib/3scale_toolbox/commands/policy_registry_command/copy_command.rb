module ThreeScaleToolbox
  module Commands
    module PolicyRegistryCommand
      module Copy
        class CopySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'copy'
              usage       'copy [opts] <source_remote> <target_remote>'
              summary     'Copy policy registry'
              description 'Copy policy registry'

              param       :source_remote
              param       :target_remote

              runner CopySubcommand
            end
          end

          def run
            source_policies = source_remote.list_policy_registry
            if source_policies.respond_to?(:has_key?) && (errors = source_policies['errors'])
              raise ThreeScaleToolbox::ThreeScaleApiError.new('Could not list source policy registry', errors)
            end

            target_policies = target_remote.list_policy_registry
            if target_policies.respond_to?(:has_key?) && (errors = target_policies['errors'])
              raise ThreeScaleToolbox::ThreeScaleApiError.new('Could not list target policy registry', errors)
            end

            # Create missing
            missing = missing_policies(source_policies, target_policies)
            missing.each do |policy|
              new_policy_registry = target_remote.create_policy_registry(policy)
              if (errors = new_policy_registry['errors'])
                raise ThreeScaleToolbox::ThreeScaleApiError.new('Could not create target policy registry', errors)
              end
            end

            # Update those matching
            matching = matching_policies(source_policies, target_policies)
            matching.each do |policy|
              updated_policy = target_remote.update_policy_registry(
                "#{policy['name']}-#{policy['version']}", policy
              )
              if (errors = updated_policy['errors'])
                raise ThreeScaleToolbox::ThreeScaleApiError.new('Could not update target policy registry', errors)
              end
            end

            puts "Created #{missing.size} missing policies on target tenant"
            puts "Updated #{matching.size} matching policies on target tenant"
          end

          private

          def missing_policies(source_policies, target_policies)
            ThreeScaleToolbox::Helper.array_difference(source_policies,
                                                       target_policies) do |source, target|
              ThreeScaleToolbox::Helper.compare_hashes(source, target, %w[name version])
            end
          end

          def matching_policies(source_policies, target_policies)
            source_policies.select do |source|
              target_policies.find do |target|
                ThreeScaleToolbox::Helper.compare_hashes(source, target, %w[name version])
              end
            end
          end

          def source_remote
            @source_remote ||= threescale_client(arguments[:source_remote])
          end

          def target_remote
            @target_remote ||= threescale_client(arguments[:target_remote])
          end
        end
      end
    end
  end
end
