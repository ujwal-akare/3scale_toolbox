module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Create
        class CreateSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'create'
              usage       'create [opts] <remote> <service> <plan-name>'
              summary     'create application plan'
              description 'Create application plan'

              option      :t, 'system-name', 'Application plan system name', argument: :required
              flag        nil, :default, 'Make default application plan'
              flag        nil, :disabled, 'Disables all methods and metrics in this application plan'
              flag        :p, :publish, 'Publish application plan'
              option      nil, 'approval-required', 'Applications require approval. true or false', argument: :required, transform: ThreeScaleToolbox::Helper::BooleanTransformer.new
              option      nil, 'cost-per-month', 'Cost per month', argument: :required, transform: method(:Float)
              option      nil, 'setup-fee', 'Setup fee', argument: :required, transform: method(:Float)
              option      nil, 'trial-period-days', 'Trial period days', argument: :required, transform: method(:Integer)
              option      nil, 'end-user-required', 'End user required. true or false', argument: :required, transform: ThreeScaleToolbox::Helper::BooleanTransformer.new
              param       :remote
              param       :service_ref
              param       :plan_name

              runner CreateSubcommand
            end
          end

          def run
            plan = create_application_plan
            plan.make_default if option_default
            plan.disable if option_disabled
            puts "Created application plan id: #{plan.id}. Default: #{option_default}; Disabled: #{option_disabled}"
          end

          private

          def create_application_plan
            ThreeScaleToolbox::Entities::ApplicationPlan.create(
              service: service,
              plan_attrs: plan_attrs
            )
          end

          def plan_attrs
            plan_basic_attrs.tap do |params|
              params['state'] = 'published' if option_publish
            end
          end

          def plan_basic_attrs
            {
              'name' => arguments[:plan_name],
              'system_name' => options[:'system-name'],
              'approval_required' => options[:'approval-required'],
              'end_user_required' => options[:'end-user-required'],
              'cost_per_month' => options[:'cost-per-month'],
              'setup_fee' => options[:'setup-fee'],
              'trial_period_days' => options[:'trial-period-days']
            }.compact
          end

          def option_default
            options.fetch(:default, false)
          end

          def option_disabled
            options.fetch(:disabled, false)
          end

          def option_publish
            options.fetch(:publish, false)
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
        end
      end
    end
  end
end
