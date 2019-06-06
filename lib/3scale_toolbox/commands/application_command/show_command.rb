module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module Show
        class ShowSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS_TO_SHOW = %w[id name description state enabled account_id service_id plan_id
                              user_key application_id application_key].freeze

          def self.command
            Cri::Command.define do
              name        'show'
              usage       'show [opts] <remote> <application>'
              summary     'show application attributes'
              description <<-HEREDOC
              Show application attributes
              \n Application param allows:
              \n * Application internal id
              \n * User_key (API key)
              \n * App_id (from app_id/app_key pair)
              \n * Client ID (for OAuth and OpenID Connect authentication modes)
              HEREDOC

              param       :remote
              param       :application

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
            puts FIELDS_TO_SHOW.map { |field| app_attrs.fetch(field, '(empty)') }.join("\t")
          end

          def app_attrs
            @app_attrs ||= application.attrs
          end

          def application
            @application ||= find_application
          end

          def find_application
            Entities::Application.find(remote: remote, ref: application_ref).tap do |app|
              raise ThreeScaleToolbox::Error, "Application #{application_ref} does not exist" if app.nil?
            end
          end

          def application_ref
            arguments[:application]
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end
        end
      end
    end
  end
end
