require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module AccountCommand
      module Find
        class FindSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'find'
              usage       'find [opts] <remote> <text>'
              summary     'find account'
              description 'Find account by email, provider key or service token'

              option      :a, :'print-all', 'Print all the account info',
                  argument: :forbidden
              param       :remote
              param       :text

              runner FindSubcommand
            end
          end

          def run
            client = threescale_client(arguments[:remote])
            begin
              account = ThreeScaleToolbox::Entities::Account.find(arguments[:text], client)
              account.verbose = options[:'print-all']
              puts account
            rescue ThreeScale::API::HttpClient::NotFoundError
              puts "Account not found"
            rescue ThreeScale::API::HttpClient::ForbiddenError
              puts "Forbidden action"
            end
          end
        end
      end
    end
  end
end
