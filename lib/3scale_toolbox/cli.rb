require '3scale_toolbox/commands'

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

  def self.run(args)
    load_builtin_commands
    ThreeScaleToolbox.load_plugins
    root_command.build_command.run args
  end
end
