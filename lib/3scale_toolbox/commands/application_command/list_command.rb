module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module List
        class ListSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS_TO_SHOW = %w[id name state enabled account_id service_id plan_id].freeze

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list [opts] <remote>'
              summary     'list applications'
              description 'List applications'

              param       :remote
              option      nil, :account, 'Filter by account', argument: :required
              option      nil, :service, 'Filter by service', argument: :required
              option      nil, :plan, 'Filter by application plan. Service option required', argument: :required

              runner ListSubcommand
            end
          end

          def run
            validate_option_params

            applications = if option_account
                             account.applications
                           elsif option_service && option_plan
                             plan.applications
                           elsif option_service
                             service.applications
                           else
                             provider_account_applications
                           end
            print_header
            print_data(applications)
          end

          private

          def validate_option_params
            raise ThreeScaleToolbox::Error, '--account and --service are mutually exclusive' \
              if option_service && option_account

            raise ThreeScaleToolbox::Error, '--plan requires --service option' \
              if option_plan && option_service.nil?
          end

          def provider_account_applications
            app_attrs_list = remote.list_applications
            if app_attrs_list.respond_to?(:has_key?) && (errors = app_attrs_list['errors'])
              raise ThreeScaleToolbox::ThreeScaleApiError.new('Provider account applications not read', errors)
            end

            app_attrs_list.map do |app_attrs|
              Entities::Application.new(id: app_attrs.fetch('id'), remote: remote, attrs: app_attrs)
            end
          end

          def option_service
            options[:service]
          end

          def option_account
            options[:account]
          end

          def option_plan
            options[:plan]
          end

          def print_header
            puts FIELDS_TO_SHOW.map(&:upcase).join("\t")
          end

          def print_data(applications)
            applications.each do |app|
              puts FIELDS_TO_SHOW.map { |field| app.attrs.fetch(field, '(empty)') }.join("\t")
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

          def account
            @account ||= find_account
          end

          def find_account
            Entities::Account.find(remote: remote,
                                   ref: option_account).tap do |acc|
              raise ThreeScaleToolbox::Error, "Account #{option_account} does not exist" if acc.nil?
            end
          end

          def plan
            @plan ||= find_plan
          end

          def find_plan
            Entities::ApplicationPlan.find(service: service, ref: option_plan).tap do |plan|
              raise ThreeScaleToolbox::Error, "Application plan #{option_plan} does not exist" if plan.nil?
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
