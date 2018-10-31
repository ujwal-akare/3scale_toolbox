
module ThreeScaleToolbox
  module Command
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
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

    def config
      @config ||= ThreeScaleToolbox::Configuration.new(config_file)
    end

    def config_file
      options[:'config-file']
    end

    def verify_ssl
      # this is flag. It is either true or false. Cannot be nil
      !options[:insecure]
    end

    def exit_with_message(message)
      puts message
      exit 1
    end

    def fetch_required_option(key)
      options.fetch(key) { exit_with_message "error: Missing argument #{key}" }
    end
  end
end
