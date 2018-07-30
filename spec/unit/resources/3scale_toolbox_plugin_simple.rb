require '3scale_toolbox/cli'

class SimpleCommand < Cri::CommandRunner
  extend ThreeScaleToolbox::Command

  def self.command
    Cri::Command.define do
      name        'simple'
      usage       'simple'
      summary     '3scale simple test command'
      description '3scale simple test command'
      runner SimpleCommand
    end
  end

  def run
    puts 'this is simple command'
  end
end
ThreeScaleToolbox::CLI.add_command(SimpleCommand)
