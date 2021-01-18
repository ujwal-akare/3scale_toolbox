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
            source_backend = Entities::Backend.new(id: backend_usage.backend_id, remote: source_remote)
            backend_context = create_backend_context(source_backend)

            tasks = []
            tasks << Commands::BackendCommand::CopyCommand::CreateOrUpdateTargetBackendTask.new(backend_context)
            # First metrics as methods need 'hits' metric in target backend
            tasks << Commands::BackendCommand::CopyCommand::CopyMetricsTask.new(backend_context)
            tasks << Commands::BackendCommand::CopyCommand::CopyMethodsTask.new(backend_context)
            tasks << Commands::BackendCommand::CopyCommand::CopyMappingRulesTask.new(backend_context)
            tasks.each(&:call)

            # CreateOrUpdate task will keep reference of the target backend in
            # backend_context[:target_backend]
            attrs = {
              'backend_api_id' => backend_context[:target_backend].id,
              'path' => backend_usage.path
            }
            # It is assumed there is no target backend usage with this backend_source's path
            # DeleteExistingTargetBackendUsagesTask should provide that
            Entities::BackendUsage.create(product: target, attrs: attrs)
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

          def create_backend_context(source_backend)
            {
              source_remote: source_remote,
              target_remote: target_remote,
              source_backend: source_backend,
              source_backend_ref: source_backend.id
            }
          end
        end
      end
    end
  end
end
