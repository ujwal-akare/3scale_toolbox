module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module Apply
        class CustomPrinter
          attr_reader :option_resume, :option_suspend

          def initialize(options)
            @option_resume = options[:resume]
            @option_suspend = options[:suspend]
          end

          def print_record(application)
            output_msg_array = ["Applied application id: #{application['id']}"]
            output_msg_array << 'Resumed' if option_resume
            output_msg_array << 'Suspended' if option_suspend
            puts output_msg_array.join('; ')
          end

          def print_collection(collection) end
        end

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
              \n * User_key (API key)
              \n * App_id (from app_id/app_key pair) or Client ID (for OAuth and OpenID Connect authentication modes)
              \n * Application internal id
              HEREDOC

              option      nil, 'user-key', 'User Key (API Key) of the application to be created.', argument: :required
              option      nil, 'application-key', 'App Key(s) or Client Secret (for OAuth and OpenID Connect authentication modes) of the application to be created. Only used when application does not exist.' , argument: :required
              option      nil, :description, 'Application description', argument: :required
              option      nil, :name, 'Application name', argument: :required
              option      nil, :account, 'Application\'s account. Required when creating', argument: :required
              option      nil, :service, 'Application\'s service. Required when creating', argument: :required
              option      nil, :plan, 'Application\'s plan. Required when creating', argument: :required
              option      nil, :'redirect-url', 'OpenID Connect redirect url', argument: :required
              flag        nil, :resume, 'Resume a suspended application'
              flag        nil, :suspend, 'Suspends an application (changes the state to suspended)'
              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :application

              runner ApplySubcommand
            end
          end

          def run
            validate_option_params

            application = Entities::Application.find(remote: remote, service_id: service_id,
                                                     ref: application_ref)
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

            printer.print_record application.attrs
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
            raise ThreeScaleToolbox::Error, "Service #{option_service} does not exist" if service.nil?

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
              'redirect_url' => option_redirect_url,
            }.compact
          end

          def app_attrs
            # This apply command does not update App Key (or Client Secret).
            # Hence, not included.
            {
              'name' => option_name,
              'description' => description,
              'user_key' => option_user_key,
              'redirect_url' => option_redirect_url,
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

          def service_id
            return if service.nil?

            service.id
          end

          def service
            return @service if defined? @service

            @service = find_service
          end

          def find_service
            return Entities::Service.find(remote: remote, ref: option_service) unless option_service.nil?
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

          def option_redirect_url
            options[:'redirect-url']
          end

          def printer
            if options.key?(:output)
              options.fetch(:output)
            else
              # keep backwards compatibility
              CustomPrinter.new(resume: option_resume, suspend: option_suspend)
            end
          end
        end
      end
    end
  end
end
