require '3scale_toolbox/commands/product_command/export_command/step'
require '3scale_toolbox/commands/product_command/export_command/read_product'
require '3scale_toolbox/commands/product_command/export_command/serialize'

module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class ExportSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'export'
            usage       'export [opts] <remote> <product>'
            summary     'Export product to yaml format'
            description 'This command serializes the referenced product into a yaml format'

            option      :f, :file, 'Write to file instead of stdout', argument: :required
            param       :remote
            param       :product_ref

            runner ExportSubcommand
          end
        end

        def run
          tasks = []
          tasks << ReadProductStep.new(context)
          tasks << SerializeStep.new(context)
          tasks.each(&:call)
        end

        private

        def context
          @context ||= create_context
        end

        def create_context
          {
            file: options[:file],
            threescale_client: threescale_client(arguments[:remote]),
            product_ref: arguments[:product_ref]
          }
        end
      end
    end
  end
end
