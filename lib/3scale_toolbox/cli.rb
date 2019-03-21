require '3scale_toolbox/cli/error_handler'

module ThreeScaleToolbox::CLI
  def self.root_command
    ThreeScaleToolbox::Commands::ThreeScaleCommand
  end

  def self.add_command(command)
    root_command.add_subcommand(command)
  end

  def self.load_builtin_commands
    ThreeScaleToolbox::Commands::BUILTIN_COMMANDS.each(&method(:add_command))
  end

  def self.install_signal_handlers
    # Set exit handler
    # Only OS supported signals
    available_signals = %w[INT TERM].select { |signal_name| Signal.list.key? signal_name }
    available_signals.each do |signal|
      Signal.trap(signal) do
        puts
        exit!(0)
      end
    end

    # Set stack trace dump handler
    if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'jruby'
      if Signal.list.key? 'USR1'
        Signal.trap('USR1') do
          puts 'Caught USR1; dumping a stack trace'
          puts caller.map { |i| "  #{i}" }.join("\n")
        end
      end
    end
  end

  def self.run(args)
    install_signal_handlers
    err = ErrorHandler.error_watchdog do
      load_builtin_commands
      ThreeScaleToolbox.load_plugins
      root_command.build_command.run args
    end
    err.nil? ? 0 : 1
  end
end
