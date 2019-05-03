module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Show
        class ShowSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS_TO_SHOW = %w[id name system_name approval_required end_user_required
                              cost_per_month setup_fee trial_period_days].freeze

          def self.command
            Cri::Command.define do
              name        'show'
              usage       'show [opts] <remote> <service> <plan>'
              summary     'show application plan'
              description 'show application plan'

              param       :remote
              param       :service_ref
              param       :plan_ref

              runner ShowSubcommand
            end
          end

          def run
            print_header
            print_data
          end

          private

          def print_header
            puts FIELDS_TO_SHOW.map(&:upcase).join("\t")
          end

          def print_data
            puts FIELDS_TO_SHOW.map { |field| plan_attrs.fetch(field, '(empty)') }.join("\t")
          end

          def service
            @service ||= find_service
          end

          def plan_attrs
            @plan_attrs ||= plan.attrs
          end

          def plan
            @plan ||= find_plan
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def find_plan
            Entities::ApplicationPlan.find(service: service, ref: plan_ref).tap do |p|
              raise ThreeScaleToolbox::Error, "Application plan #{plan_ref} does not exist" if p.nil?
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
        end
      end
    end
  end
end
