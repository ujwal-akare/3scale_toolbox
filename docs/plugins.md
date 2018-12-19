# Developing 3scale Toolbox CLI plugins

3scale toolbox is based on the [cri](https://github.com/ddfreyne/cri) library for building command line tools.

The plugin system also uses [cri](https://github.com/ddfreyne/cri) to leverage its easy to develop, flexible and extensible plugin system.

The  3scale Toolbox will load plugins installed in gems or $LOAD_PATH. Plugins are discovered via *Gem::find_files*, then loaded.
Plugins must be named ‘3scale_toolbox_plugin’ (.rb, .so, etc) and placed in the root of your gem’s #require_path.

Plugins may add commands to *3scale* toolbox or may add *subcommands* to any existing command.
Subcommands may be added to main commands or other subcommands as children.

Nothing better than few examples to illustrate.

## Plugin command

Let's create a plugin to add a `supercool` command. The simplest command ever,
but useful to ilustrate basic command code skeleton or structure.

Source code can be find [here](https://github.com/eguzki/3scale_toolbox_plugin_demo)

```
$ cat lib/3scale_toolbox_plugin.rb
class SupercoolCommand < Cri::CommandRunner
  include ThreeScaleToolbox::Command

  def self.command
    Cri::Command.define do
      name        'supercool'
      usage       'supercool [options]'
      summary     '3scale supercool'
      description '3scale supercool command'
      runner SupercoolCommand
    end
  end

  def run
    puts 'Doing lots of things!'
  end
end
ThreeScaleToolbox::CLI.add_command(SupercoolCommand)

$ RUBYOPT=-Ilib 3scale supercool
Doing lots of things!
```
A few things worth highlighting:
- Your module must include the *ThreeScaleToolbox::Command* module. It allows your command to be added to the toobox command tree.
- You must implement the `command` module function and return an instance of `Cri::Command` from [cri](https://github.com/ddfreyne/cri)
- Add your command to `3scale` toolbox command tree by calling `ThreeScaleToolbox::CLI.add_command`

Help for your plugin is also available using builtin *help* command

```
$ RUBYOPT=-Ilib 3scale help foo
NAME
    supercool - 3scale supercool

USAGE
    3scale supercool [options]

DESCRIPTION
    3scale supercool command

OPTIONS FOR 3SCALE
    -c --config-file=<value>      3scale CLI configuration file (default:
                                  /opt/app-root/src/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
```
## Plugin subcommand

Let's create a plugin to add a `supercool` subcommand for the toolbox core *copy* command.
```
$ cat lib/3scale_toolbox_plugin.rb
class SupercoolCommand < Cri::CommandRunner
  include ThreeScaleToolbox::Command

  def self.command
    Cri::Command.define do
      name        'supercool'
      usage       'supercool [options]'
      summary     '3scale supercool'
      description '3scale supercool command'
      runner SupercoolCommand
    end
  end

  def run
    puts 'Doing lots of things!'
  end
end
ThreeScaleToolbox::Commands::CopyCommand.add_subcommand(SupercoolCommand)

# RUBYOPT=-Ilib 3scale copy supercool
Doing lots of things!
```
A few things worth highlighting:
- Your module must include the *ThreeScaleToolbox::Command* module. It allows your command to be added to the toolbox command tree.
- You must implement the `command` module function and return an instance of `Cri::Command` from [cri](https://github.com/ddfreyne/cri)
- Add your subcommand to `3scale` toolbox command tree by calling the parent command's module's `add_subcommand` method.

Checking the `copy` command's help, we can verify the new subcommand `foo` has been added.

```
$ RUBYOPT=-Ilib 3scale help copy
NAME
    copy - 3scale copy command

USAGE
    3scale copy <sub-command> [options]

DESCRIPTION
    3scale copy command.

SUBCOMMANDS
    service       Copy service
    supercool     3scale supercool

OPTIONS FOR 3SCALE
    -c --config-file=<value>      3scale CLI configuration file (default:
                                  /opt/app-root/src/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
```

Now, package your plugin as a [gem](https://guides.rubygems.org/make-your-own-gem/) and let us know about it.

## Existing Plugins
