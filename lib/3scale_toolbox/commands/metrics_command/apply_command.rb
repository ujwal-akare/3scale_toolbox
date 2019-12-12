module ThreeScaleToolbox
  module Commands
    module MetricsCommand
      module Apply
        class CustomPrinter
          attr_reader :option_disabled, :option_enabled

          def initialize(options)
            @option_disabled = options[:disabled]
            @option_enabled = options[:enabled]
          end

          def print_record(metric)
            output_msg_array = ["Applied metric id: #{metric['id']}"]
            output_msg_array << 'Disabled' if option_disabled
            output_msg_array << 'Enabled' if option_enabled
            puts output_msg_array.join('; ')
          end

          def print_collection(collection) end
        end

        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply [opts] <remote> <service> <metric>'
              summary     'Update metric'
              description 'Update (create if it does not exist) metric'

              option      :n, :name, 'Metric name', argument: :required
              flag        nil, :disabled, 'Disables this metric in all application plans'
              flag        nil, :enabled, 'Enables this metric in all application plans'
              option      nil, :unit, 'Metric unit. Default hit', argument: :required
              option      nil, :description, 'Metric description', argument: :required
              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :service_ref
              param       :metric_ref

              runner ApplySubcommand
            end
          end

          def run
            validate_option_params
            metric = Entities::Metric.find(service: service, ref: metric_ref)
            if metric.nil?
              metric = Entities::Metric.create(service: service,
                                               attrs: create_metric_attrs)
            else
              metric.update(metric_attrs) unless metric_attrs.empty?
            end

            metric.disable if option_disabled
            metric.enable if option_enabled

            printer.print_record metric.attrs
          end

          private

          def validate_option_params
            raise ThreeScaleToolbox::Error, '--disabled and --enabled are mutually exclusive' \
              if option_enabled && option_disabled
          end

          def create_metric_attrs
            metric_attrs.merge('system_name' => metric_ref,
                               'unit' => 'hit',
                               'friendly_name' => metric_ref) { |_key, oldval, _newval| oldval }
          end

          def metric_attrs
            {
              'friendly_name' => options[:name],
              'unit' => options[:unit],
              'description' => options[:description]
            }.compact
          end

          def option_enabled
            options.fetch(:enabled, false)
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

          def metric_ref
            arguments[:metric_ref]
          end

          def printer
            if options.key?(:output)
              options.fetch(:output)
            else
              # keep backwards compatibility
              CustomPrinter.new(disabled: option_disabled, enabled: option_enabled)
            end
          end
        end
      end
    end
  end
end
