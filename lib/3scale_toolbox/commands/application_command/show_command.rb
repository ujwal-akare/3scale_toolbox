module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module Show
        class ShowSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          FIELDS_TO_SHOW = %w[id name description state enabled account_id service_id plan_id
                              user_key application_id].freeze

          def self.command
            Cri::Command.define do
              name        'show'
              usage       'show [opts] <remote> <application>'
              summary     'show application attributes'
              description <<-HEREDOC
              Show application attributes
              \n Application param allows:
              \n * User_key (API key)
              \n * App_id (from app_id/app_key pair) or Client ID (for OAuth and OpenID Connect authentication modes)
              \n * Application internal id
              HEREDOC

              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :application

              runner ShowSubcommand
            end
          end

          def run
            printer.print_record application.attrs
          end

          private

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

          def printer
            # keep backwards compatibility
            options.fetch(:output, CLI::CustomTablePrinter.new(FIELDS_TO_SHOW))
          end
        end
      end
    end
  end
end
