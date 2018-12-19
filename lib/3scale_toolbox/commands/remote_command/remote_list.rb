module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteListSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'list'
            usage       'list'
            summary     'remote list'
            description 'List all defined remotes'
            runner RemoteListSubcommand
          end
        end

        def run
          if remotes.all.empty?
            puts 'Empty remote list.'
          else
            remotes.all.each do |name, remote|
              puts "#{name} #{remote[:endpoint]} #{remote[:authentication]}"
            end
          end
        end
      end
    end
  end
end
