require '3scale_toolbox/cli'

# `expect(...).not_to matcher.and matcher` is not supported
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

RSpec.describe 'Plugin Command Hierarchy' do
  include_context :random_name

  def create_command(command_name)
    Class.new(Cri::CommandRunner) do
      extend ThreeScaleToolbox::Command

      this_class = self
      define_singleton_method :command do
        Cri::Command.define do
          name        command_name
          usage       command_name
          runner      this_class
        end
      end

      define_method :run do
        puts "command #{command_name}"
      end
    end
  end

  it 'sibling commands loaded with add command' do
    10.times.each do |cmd_idx|
      cmd = create_command("cmd_#{cmd_idx}")
      ThreeScaleToolbox::CLI.add_command(cmd)
    end

    10.times.each do |cmd_idx|
      expect do
        ThreeScaleToolbox::CLI.run(["cmd_#{cmd_idx}"])
      end.to not_raise_error.and output("command cmd_#{cmd_idx}\n").to_stdout
    end
  end

  it '.add_subcommand' do
    base_name = random_lowercase_name
    base_cmd = create_command(base_name)
    ThreeScaleToolbox::CLI.add_command(base_cmd)

    subcmd_name = random_lowercase_name
    subcmd = create_command(subcmd_name)
    base_cmd.add_subcommand(subcmd)

    expect do
      ThreeScaleToolbox::CLI.run([base_name, subcmd_name])
    end.to not_raise_error.and output("command #{subcmd_name}\n").to_stdout
  end
end
