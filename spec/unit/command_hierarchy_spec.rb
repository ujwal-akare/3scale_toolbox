require '3scale_toolbox'

RSpec.describe 'Plugin Command Hierarchy' do
  include_context :random_name

  def create_command(command_name:, message:)
    Class.new(Cri::CommandRunner) do
      include ThreeScaleToolbox::Command

      this_class = self
      define_singleton_method :command do
        Cri::Command.define do
          name        command_name
          runner      this_class
        end
      end

      define_method :run do
        puts message
      end
    end
  end

  it '.add_command to add multiple commands at the same hierarchy level' do
    command01 = { command_name: random_lowercase_name, message: 'Lorem ipsum dolor sit amet' }
    ThreeScaleToolbox::CLI.add_command(create_command(command01))
    command02 = { command_name: random_lowercase_name, message: 'One upon a time' }
    ThreeScaleToolbox::CLI.add_command(create_command(command02))

    expect do
      ThreeScaleToolbox::CLI.run([command01[:command_name]])
    end.to output("#{command01[:message]}\n").to_stdout

    expect do
      ThreeScaleToolbox::CLI.run([command02[:command_name]])
    end.to output("#{command02[:message]}\n").to_stdout
  end

  it '.add_subcommand to add commands in parent child hierarchy' do
    base_command_info = {
      command_name: random_lowercase_name,
      message: 'Excepteur sint occaecat cupidatat non proident'
    }

    base_cmd = create_command(base_command_info)
    ThreeScaleToolbox::CLI.add_command base_cmd

    subcmd_info = {
      command_name: random_lowercase_name,
      message: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco'
    }

    base_cmd.add_subcommand(create_command(subcmd_info))

    # Calling subcommand
    expect do
      ThreeScaleToolbox::CLI.run([base_command_info[:command_name], subcmd_info[:command_name]])
    end.to output("#{subcmd_info[:message]}\n").to_stdout

    # Calling base command
    expect do
      ThreeScaleToolbox::CLI.run([base_command_info[:command_name]])
    end.to output("#{base_command_info[:message]}\n").to_stdout
  end
end
