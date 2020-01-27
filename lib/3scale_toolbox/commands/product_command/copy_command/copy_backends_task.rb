module ThreeScaleToolbox
  module Commands
    module ProductCommand
      module CopyCommand
        class CopyBackendsTask
          attr_reader :context

          def initialize(context)
            @context = context
          end

          # entrypoint
          def call
            backend_list = source.backend_usage_list
            backend_list.each(&method(:create_backend))
            puts "created/upated #{backend_list.size} backends"
          end

          private

          def create_backend(backend_usage)
            backend = Entities::Backend.new(id: backend_usage.backend_id, remote: source_remote)
            backend_context = create_backend_context(backend.system_name)

            tasks = []
            tasks << Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask.new(backend_context)
            # First metrics as methods need 'hits' metric in target backend
            tasks << Commands::BackendCommand::CopyCommand::CopyMetricsTask.new(backend_context)
            tasks << Commands::BackendCommand::CopyCommand::CopyMethodsTask.new(backend_context)
            tasks << Commands::BackendCommand::CopyCommand::CopyMappingRulesTask.new(backend_context)
            tasks.each(&:call)

            create_or_update_target_backend_usage(backend_context[:target_backend], backend_usage)
          end

          def create_or_update_target_backend_usage(target_backend, backend_usage)
            target_usage = Entities::BackendUsage.find_by_path(product: target,
                                                               path: backend_usage.path)
            if target_usage.nil?
              attrs = {
                'backend_api_id' => target_backend.id,
                'service_id' => target.id,
                'path' => backend_usage.path
              }
              Entities::BackendUsage.create(product: target, attrs: attrs)
            elsif target_usage.backend_id != target_backend.id
              target_usage.update('backend_api_id' => target_backend.id)
            end
          end

          def source
            context[:source]
          end

          def target
            context[:target]
          end

          def source_remote
            context[:source_remote]
          end

          def target_remote
            context[:target_remote]
          end

          def create_backend_context(source_backend_system_name)
            {
              source_remote: source_remote,
              target_remote: target_remote,
              source_backend_ref: source_backend_system_name
            }
          end
        end
      end
    end
  end
end
