module ThreeScaleToolbox
  module Commands
    module UpdateCommand
      module ServiceCommand
        class CopyServiceSettingsTask
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def call
            target.update source_attrs

            puts "updated service settings for service id #{source.id}..."
          end

          private

          def source
            context[:source]
          end

          def target
            context[:target]
          end

          def source_attrs
            source.attrs.reject { |k, _| %w[system_name id links].include? k }
          end
        end
      end
    end
  end
end
