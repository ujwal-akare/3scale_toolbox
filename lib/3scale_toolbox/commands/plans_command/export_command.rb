module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Export
        class ExportSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'export'
              usage       'export [opts] <remote> <service_system_name> <plan_system_name>'
              summary     'export application plan'
              description 'Export application plan, limits, pricing rules and features'

              option      :f, :file, 'Write to file instead of stdout', argument: :required
              param       :remote
              param       :service_system_name
              param       :plan_system_name

              runner ExportSubcommand
            end
          end

          def run
            select_output do |output|
              plan_object = application_plan.to_hash.merge(
                'created_at' => Time.now.utc.iso8601,
                'toolbox_version' => ThreeScaleToolbox::VERSION
              )
              output.write(plan_object.to_yaml)
            end
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def select_output
            ios = if file
                    File.open(file, 'w')
                  else
                    $stdout
                  end
            begin
              yield(ios)
            ensure
              ios.close
            end
          end

          def application_plan
            @application_plan ||= find_application_plan
          end

          def find_application_plan
            Entities::ApplicationPlan.find(service: product, ref: plan_system_name).tap do |p|
              raise ThreeScaleToolbox::Error, "Application plan #{plan_system_name} does not exist" if p.nil?
            end
          end

          def product
            @product ||= find_product
          end

          def product_ref
            arguments[:service_system_name]
          end

          def plan_system_name
            arguments[:plan_system_name]
          end

          def find_product
            Entities::Service.find(remote: remote, ref: product_ref).tap do |prd|
              raise ThreeScaleToolbox::Error, "Product #{product_ref} does not exist" if prd.nil?
            end
          end

          def file
            options[:file]
          end
        end
      end
    end
  end
end
