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

              option      :a, :'print-all', 'Print all the account info', argument: :forbidden
              param       :remote
              param       :text

              runner FindSubcommand
            end
          end

          def run
            client = threescale_client(arguments[:remote])
            account = ThreeScaleToolbox::Entities::Account.find_by_text(arguments[:text], client)
            if account.nil?
              puts 'Account not found'
              return
            end

            account.verbose = options[:'print-all']
            puts account
          end
        end
      end
    end
  end
end
