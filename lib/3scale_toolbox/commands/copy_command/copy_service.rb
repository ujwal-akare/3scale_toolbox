module ThreeScaleToolbox
  module Commands
    module CopyCommand
      class CopyServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <source-service>'
            summary     'copy service'
            description <<-HEREDOC
            This command makes a copy of the referenced service.
            Target service will be searched by source service system name. System name can be overriden with `--target_system_name` option.
            If a service with the selected `system_name` is not found, it will be created.
            \n Components of the service being copied:
            \nservice settings
            \nproxy settings
            \npricing rules
            \nactivedocs
            \nmetrics
            \nmethods
            \napplication plans
            \nmapping rules
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name. Default to source system name', argument: :required
            flag    :f, :force, 'Overwrites the mapping rules by deleting all rules from target service first'
            flag    :r, 'rules-only', 'Only mapping rules are copied'
            param   :source_service

            runner CopyServiceSubcommand
          end
        end

        def run
          target_service = Entities::Service.find(remote: target_remote,
                                                  ref: target_service_ref)

          target_service_new = target_service.nil?
          if target_service_new
            target_service = Entities::Service.create(remote: target_remote,
                                                      service_params: create_service_attrs)
          end

          if target_service == source_service
            raise ThreeScaleToolbox::Error, 'Source and destination services are the same: ' \
              "ID: #{source_service.id} system_name: #{source_service.attrs['system_name']}"
          end

          puts "new service id #{target_service.id}"

          context = create_context(source_service, target_service)

          tasks = []
          unless option_rules_only
            tasks << Tasks::CopyServiceSettingsTask.new(context)
            tasks << Tasks::CopyServiceProxyTask.new(context)
            tasks << Tasks::CopyMethodsTask.new(context)
            tasks << Tasks::CopyMetricsTask.new(context)
            tasks << Tasks::CopyApplicationPlansTask.new(context)
            tasks << Tasks::CopyLimitsTask.new(context)
            tasks << Tasks::CopyPoliciesTask.new(context)
            tasks << Tasks::CopyPricingRulesTask.new(context)
            tasks << Tasks::CopyActiveDocsTask.new(context)
          end
          tasks << Tasks::DestroyMappingRulesTask.new(context) if option_force || target_service_new
          tasks << Tasks::CopyMappingRulesTask.new(context)
          tasks.each(&:call)

          # This should be the last step
          Tasks::BumpProxyVersionTask.new(service: target_service).call
        end

        private

        def create_context(source, target)
          {
            source: source,
            target: target
          }
        end

        def option_rules_only
          options[:'rules-only']
        end

        def option_force
          options[:force]
        end

        def option_target_system_name
          options[:target_system_name]
        end

        def create_service_attrs
          # minimum required attrs.
          # Service settings will be updated in later task
          # These attrs are only when service is created
          {
            'name' => source_service.attrs.fetch('name'),
            'system_name' => target_service_ref
          }.compact
        end

        def source_service
          @source_service ||= find_source_service
        end

        def find_source_service
          Entities::Service.find(remote: source_remote, ref: source_service_ref).tap do |svc|
            raise ThreeScaleToolbox::Error, "Service #{source_service_ref} does not exist" if svc.nil?
          end
        end

        def source_remote
          @source_remote ||= threescale_client(source)
        end

        def target_remote
          @target_remote ||= threescale_client(target)
        end

        def source_service_ref
          arguments[:source_service]
        end

        def target_service_ref
          option_target_system_name || source_service.attrs.fetch('system_name')
        end

        def source
          fetch_required_option(:source)
        end

        def target
          fetch_required_option(:destination)
        end
      end
    end
  end
end
