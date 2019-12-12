module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Apply
        class CustomPrinter
          attr_reader :option_default, :option_disabled, :option_enabled,
                      :option_publish, :option_hide

          def initialize(options)
            @option_default = options[:default]
            @option_disabled = options[:disabled]
            @option_enabled = options[:enabled]
            @option_publish = options[:publish]
            @option_hide = options[:hide]
          end

          def print_record(plan)
            output_msg_array = ["Applied application plan id: #{plan['id']}"]
            output_msg_array << "Default: #{option_default}"
            output_msg_array << 'Disabled' if option_disabled
            output_msg_array << 'Enabled' if option_enabled
            output_msg_array << 'Published' if option_publish
            output_msg_array << 'Hidden' if option_hide
            puts output_msg_array.join('; ')
          end

          def print_collection(collection) end
        end

        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply [opts] <remote> <service> <plan>'
              summary     'Update application plan'
              description 'Update (create if it does not exist) application plan'

              option      :n, :name, 'Plan name', argument: :required
              flag        nil, :default, 'Make default application plan'
              flag        nil, :disabled, 'Disables all methods and metrics in this application plan'
              flag        nil, :enabled, 'Enable application plan'
              flag        :p, :publish, 'Publish application plan'
              flag        nil, :hide, 'Hide application plan'
              option      nil, 'approval-required', 'Applications require approval. true or false', argument: :required, transform: ThreeScaleToolbox::Helper::BooleanTransformer.new
              option      nil, 'cost-per-month', 'Cost per month', argument: :required, transform: method(:Float)
              option      nil, 'setup-fee', 'Setup fee', argument: :required, transform: method(:Float)
              option      nil, 'trial-period-days', 'Trial period days', argument: :required, transform: method(:Integer)
              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :service_ref
              param       :plan_ref

              runner ApplySubcommand
            end
          end

          def run
            validate_option_params
            plan = Entities::ApplicationPlan.find(service: service, ref: plan_ref)
            if plan.nil?
              plan = Entities::ApplicationPlan.create(service: service,
                                                      plan_attrs: create_plan_attrs)
            else
              plan.update(new_plan_attrs) unless new_plan_attrs.empty?
            end

            plan.make_default if option_default
            plan.disable if option_disabled
            plan.enable if option_enabled

            printer.print_record plan.attrs
          end

          private

          def validate_option_params
            raise ThreeScaleToolbox::Error, '--disabled and --enabled are mutually exclusive' \
              if option_enabled && option_disabled

            raise ThreeScaleToolbox::Error, '--publish and --hide are mutually exclusive' \
              if option_publish && option_hide
          end

          def create_plan_attrs
            new_attrs = plan_basic_attrs.merge('name' => plan_ref) { |_key, oldval, _newval| oldval }
            new_attrs.tap do |params|
              params['system_name'] = plan_ref
              params['state'] = 'published' if option_publish
            end
          end

          def new_plan_attrs
            plan_basic_attrs.clone.tap do |params|
              params['state'] = 'published' if option_publish
              params['state'] = 'hidden' if option_hide
            end
          end

          def plan_basic_attrs
            {
              'name' => options[:name],
              'approval_required' => options[:'approval-required'],
              'cost_per_month' => options[:'cost-per-month'],
              'setup_fee' => options[:'setup-fee'],
              'trial_period_days' => options[:'trial-period-days']
            }.compact
          end

          def option_default
            options.fetch(:default, false)
          end

          def option_enabled
            options.fetch(:enabled, false)
          end

          def option_disabled
            options.fetch(:disabled, false)
          end

          def option_publish
            options.fetch(:publish, false)
          end

          def option_hide
            options.fetch(:hide, false)
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

          def plan_ref
            arguments[:plan_ref]
          end

          def printer
            # keep backwards compatibility
            options.fetch(:output,
                          CustomPrinter.new(default: option_default, disabled: option_disabled,
                                            enabled: option_enabled, publish: option_publish,
                                            hide: option_hide))
          end
        end
      end
    end
  end
end
