module ThreeScaleToolbox
  module Commands
    module MetricsCommand
      module Create
        class CustomPrinter
          attr_reader :option_disabled

          def initialize(options)
            @option_disabled = options[:disabled]
          end

          def print_record(metric)
            puts "Created metric id: #{metric['id']}. Disabled: #{option_disabled}"
          end

          def print_collection(collection) end
        end

        class CreateSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'create'
              usage       'create [opts] <remote> <service> <metric-name>'
              summary     'create metric'
              description 'Create metric'

              option      :t, 'system-name', 'Metric system name', argument: :required
              flag        nil, :disabled, 'Disables this metric in all application plans'
              option      nil, :unit, 'Metric unit. Default hit', argument: :required
              option      nil, :description, 'Metric description', argument: :required
              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :service_ref
              param       :metric_name

              runner CreateSubcommand
            end
          end

          def run
            metric = ThreeScaleToolbox::Entities::Metric.create(
              service: service,
              attrs: metric_attrs
            )
            metric.disable if option_disabled

            printer.print_record metric.attrs
          end

          private

          def metric_attrs
            {
              'system_name' => options[:'system-name'],
              'unit' => unit,
              'friendly_name' => arguments[:metric_name],
              'description' => options[:description]
            }.compact
          end

          def unit
            options[:unit] || 'hit'
          end

          def option_disabled
            options.fetch(:disabled, false)
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end

          def printer
            if options.key?(:output)
              options.fetch(:output)
            else
              # keep backwards compatibility
              CustomPrinter.new(disabled: option_disabled)
            end
          end
        end
      end
    end
  end
end
