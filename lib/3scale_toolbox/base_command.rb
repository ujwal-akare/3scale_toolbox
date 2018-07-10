
module ThreeScaleToolbox
  module Command
    def subcommands
      @subcommands ||= []
    end

    def add_subcommand(command)
      subcommands << command
    end

    ##
    # Override to command
    #
    def command
      raise Exception, 'base command has no command definition'
    end

    ##
    # Iterate recursively over command tree
    #
    def build_command
      subcommands.each_with_object(command) do |subcommand, root_command|
        root_command.add_command(subcommand.build_command)
      end
    end
  end
end
