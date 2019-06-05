module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module Create
        class CreateSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'create'
              usage       'create [opts] <remote> <account> <service> <application-plan> <name>'
              summary     'create one application'
              description 'create one application linked to given account and application plan'

              option      nil, 'user-key', 'User Key (API Key) of the application to be created.', argument: :required
              option      nil, 'application-id', 'App ID or Client ID (for OAuth and OpenID Connect authentication modes) of the application to be created. ', argument: :required
              option      nil, 'application_key', 'App ID or Client ID (for OAuth and OpenID Connect authentication modes) of the application to be created.', argument: :required
              option      nil, :description, 'Application description', argument: :required
              param       :remote
              param       :account
              param       :service
              param       :plan
              param       :name

              runner CreateSubcommand
            end
          end

          def run
            application = ThreeScaleToolbox::Entities::Application.create(
              remote: remote,
              account_id: account.id,
              plan_id: plan.id,
              app_attrs: app_attrs
            )

            puts "Created application id: #{application.id}"
          end

          private

          def app_attrs
            {
              'name' => name,
              'description' => description,
              'user_key' => options[:'user-key'],
              'application_id' => options[:'application-id'],
              'application_key' => options[:'application-key']
            }.compact
          end

          def description
            options[:description] || name
          end

          def name
            arguments[:name]
          end

          def account_ref
            arguments[:account]
          end

          def account
            @account ||= find_account
          end

          def find_account
            Entities::Account.find(remote: remote,
                                   ref: account_ref).tap do |acc|
              raise ThreeScaleToolbox::Error, "Account #{account_ref} does not exist" if acc.nil?
            end
          end

          def service_ref
            arguments[:service]
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service.find(remote: remote, ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def plan_ref
            arguments[:plan]
          end

          def plan
            @plan ||= find_plan
          end

          def find_plan
            Entities::ApplicationPlan.find(service: service, ref: plan_ref).tap do |plan|
              raise ThreeScaleToolbox::Error, "Application plan #{plan_ref} does not exist" if plan.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end
        end
      end
    end
  end
end
