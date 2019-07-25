module ThreeScaleToolbox
  module Commands
    module ApplicationCommand
      module Delete
        class DeleteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'delete'
              usage       'delete [opts] <remote> <application>'
              summary     'delete application'
              description <<-HEREDOC
              Delete application'
              \n Application param allows:
              \n * User_key (API key)
              \n * App_id (from app_id/app_key pair) or Client ID (for OAuth and OpenID Connect authentication modes)
              \n * Application internal id
              HEREDOC

              param       :remote
              param       :application_ref

              runner DeleteSubcommand
            end
          end

          def run
            application.delete
            puts "Application id: #{application.id} deleted"
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

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def application_ref
            arguments[:application_ref]
          end
        end
      end
    end
  end
end
