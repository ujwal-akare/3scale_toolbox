module ThreeScaleToolbox
  module Commands
    module ActiveDocsCommand
      module Delete
        class DeleteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'delete'
              usage       'delete <remote> <activedocs-id_or-system-name>'
              summary     'Delete an ActiveDocs'
              description 'Remove an ActiveDocs'
              runner DeleteSubcommand

              param   :remote
              param   :activedocs_id_or_system_name
            end
          end

          def run
            activedocs.delete
            puts "ActiveDocs with id: #{activedocs.id} deleted"
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def ref
            arguments[:activedocs_id_or_system_name]
          end

          def activedocs
            @activedocs ||= find_activedocs
          end

          def find_activedocs
            Entities::ActiveDocs.find(remote: remote, ref: ref).tap do |activedoc|
              raise ThreeScaleToolbox::Error, "ActiveDocs #{ref} does not exist" if activedoc.nil?
            end
          end
        end
      end
    end
  end
end