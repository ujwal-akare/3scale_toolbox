module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Show
        class ShowSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS_TO_SHOW = %w[id name system_name approval_required
                              cost_per_month setup_fee trial_period_days].freeze

          def self.command
            Cri::Command.define do
              name        'show'
              usage       'show [opts] <remote> <service> <plan>'
              summary     'show application plan'
              description 'show application plan'

              ThreeScaleToolbox::CLI.output_flag(self)
              param       :remote
              param       :service_ref
              param       :plan_ref

              runner ShowSubcommand
            end
          end

          def run
            printer.print_record plan.attrs
          end

          private

          def service
            @service ||= find_service
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

          def printer
            options.fetch(:output, CLI::CustomTablePrinter.new(FIELDS_TO_SHOW))
          end
        end
      end
    end
  end
end
