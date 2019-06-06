module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module Apply
        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply [opts] <remote> <application>'
              summary     'update (or create) application'
              description <<-HEREDOC
              Update (create if it does not exist) application'
              \n Application param allows:
              \n * Application internal id
              \n * User_key (API key)
              \n * App_id (from app_id/app_key pair)
              \n * Client ID (for OAuth and OpenID Connect authentication modes)
              HEREDOC

              option      nil, 'user-key', 'User Key (API Key) of the application to be created.', argument: :required
              option      nil, 'application-key', 'App Key(s) or Client Secret (for OAuth and OpenID Connect authentication modes) of the application to be created. Only used when application does not exist.' , argument: :required
              option      nil, :description, 'Application description', argument: :required
              option      nil, :name, 'Application name', argument: :required
              option      nil, :account, 'Application\'s account. Required when creating', argument: :required
              option      nil, :service, 'Application\'s service. Required when creating', argument: :required
              option      nil, :plan, 'Application\'s plan. Required when creating', argument: :required
              flag        nil, :resume, 'Resume a suspended application'
              flag        nil, :suspend, 'Suspends an application (changes the state to suspended)'
              param       :remote
              param       :application

              runner ApplySubcommand
            end
          end

          def run
            validate_option_params

            application = Entities::Application.find(remote: remote, ref: application_ref)
            if application.nil?
              validate_creation_option_params
              application = Entities::Application.create(remote: remote,
                                                         account_id: account.id,
                                                         plan_id: plan.id,
                                                         app_attrs: create_app_attrs)
            else
              application.update(app_attrs) unless app_attrs.empty?
            end

            application.resume if option_resume
            application.suspend if option_suspend
            output_msg_array = ["Applied application id: #{application.id}"]
            output_msg_array << 'Resumed' if option_resume
            output_msg_array << 'Suspended' if option_suspend
            puts output_msg_array.join('; ')
          end

          private

          def validate_option_params
            raise ThreeScaleToolbox::Error, '--resume and --suspend are mutually exclusive' \
              if option_resume && option_suspend
          end

          def validate_creation_option_params
            raise ThreeScaleToolbox::Error, "Application #{application_ref} does not exist." \
              '--account is required to create' if option_account.nil?
            raise ThreeScaleToolbox::Error, "Application #{application_ref} does not exist." \
              '--service is required to create' if option_service.nil?
            raise ThreeScaleToolbox::Error, "Application #{application_ref} does not exist." \
              '--plan is required to create' if option_plan.nil?
            raise ThreeScaleToolbox::Error, "Application #{application_ref} does not exist." \
              '--name is required to create' if option_name.nil?
            raise ThreeScaleToolbox::Error, "Application #{application_ref} does not exist." \
              '--user-key option forbidden' unless option_user_key.nil?
          end

          def create_app_attrs
            {
              'name' => option_name,
              'description' => description,
              'user_key' => application_ref,
              'application_id' => application_ref,
              'application_key' => option_app_key,
            }.compact
          end

          def app_attrs
            # This apply command does not update App Key (or Client Secret).
            # Hence, not included.
            {
              'name' => option_name,
              'description' => description,
              'user_key' => option_user_key,
            }.compact
          end

          def account
            @account ||= find_account
          end

          def find_account
            Entities::Account.find(remote: remote,
                                   ref: option_account).tap do |acc|
              raise ThreeScaleToolbox::Error, "Account #{option_account} does not exist" if acc.nil?
            end
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: option_service).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{option_service} does not exist" if svc.nil?
            end
          end

          def plan
            @plan ||= find_plan
          end

          def find_plan
            Entities::ApplicationPlan.find(service: service, ref: option_plan).tap do |pl|
              raise ThreeScaleToolbox::Error, "Application plan #{option_plan} does not exist" if pl.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def option_name
            options[:name]
          end

          def description
            options[:description] || option_name
          end

          def option_user_key
            options[:'user-key']
          end

          def option_app_key
            options[:'application-key']
          end

          def option_account
            options[:account]
          end

          def option_service
            options[:service]
          end

          def option_plan
            options[:plan]
          end

          def option_resume
            options.fetch(:resume, false)
          end

          def option_suspend
            options.fetch(:suspend, false)
          end

          def application_ref
            arguments[:application]
          end
        end
      end
    end
  end
end
