module ThreeScaleToolbox
  module Commands
    module MethodsCommand
      module Apply
        class CustomPrinter
          attr_reader :option_disabled, :option_enabled

          def initialize(options)
            @option_disabled = options[:disabled]
            @option_enabled = options[:enabled]
          end

          def print_record(method)
            output_msg_array = ["Applied method id: #{method['id']}"]
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
              usage       'apply [opts] <remote> <service> <method>'
              summary     'Update method'
              description 'Update (create if it does not exist) method'

              option      :n, :name, 'Method name', argument: :required
              flag        nil, :disabled, 'Disables this method in all application plans'
              flag        nil, :enabled, 'Enables this method in all application plans'
              option      nil, :description, 'Method description', argument: :required
              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :service_ref
              param       :method_ref

              runner ApplySubcommand
            end
          end

          def run
            validate_option_params
            hits = service.hits
            method = Entities::Method.find(service: service, ref: method_ref)
            if method.nil?
              method = Entities::Method.create(service: service, attrs: create_method_attrs)
            else
              method.update(method_attrs) unless method_attrs.empty?
            end

            method.disable if option_disabled
            method.enable if option_enabled

            printer.print_record method.attrs
          end

          private

          def validate_option_params
            raise ThreeScaleToolbox::Error, '--disabled and --enabled are mutually exclusive' \
              if option_enabled && option_disabled
          end

          def create_method_attrs
            method_attrs.merge('system_name' => method_ref,
                               'friendly_name' => method_ref) { |_key, oldval, _newval| oldval }
          end

          def method_attrs
            {
              'friendly_name' => options[:name],
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

          def method_ref
            arguments[:method_ref]
          end

          def printer
            # keep backwards compatibility
            options.fetch(:output, CustomPrinter.new(disabled: option_disabled, enabled: option_enabled))
          end
        end
      end
    end
  end
end
