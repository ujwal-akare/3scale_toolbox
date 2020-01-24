module ThreeScaleToolbox
  module Commands
    module CopyCommand
      class ServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <source-service>'
            summary     'copy service'
            description <<-HEREDOC
            This command makes a copy of the referenced service.
            Target service will be searched by source service system name. System name can be overriden with `--target_system_name` option.
            If a service with the selected `system_name` is not found, it will be created.
            \n Components of the service being copied:
            \nservice settings
            \nproxy settings
            \npricing rules
            \nactivedocs
            \nmetrics
            \nmethods
            \napplication plans
            \nmapping rules
            HEREDOC

            option  :s, :source, '3scale source instance. Url or remote name', argument: :required
            option  :d, :destination, '3scale target instance. Url or remote name', argument: :required
            option  :t, 'target_system_name', 'Target system name. Default to source system name', argument: :required
            flag    :f, :force, 'Overwrites the mapping rules by deleting all rules from target service first'
            flag    :r, 'rules-only', 'Only mapping rules are copied'
            param   :source_service

            runner Commands::ServiceCommand::CopySubcommand
          end
        end
      end
    end
  end
end
