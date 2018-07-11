# Developing 3scale Toolbox CLI plugins

3scale Toolbox CLI is based on [cri](https://github.com/ddfreyne/cri) library for building command line tools.
Plugin system also uses [cri](https://github.com/ddfreyne/cri) to leverage easy to develop, flexible and extensible plugin system.

3scale Toolbox will load plugins installed in gems or $LOAD_PATH. Plugins are discovered via *Gem::find_files*, then loaded.
Plugins must be named ‘3scale_toolbox_plugin’ (.rb, .so, etc) and placed at the root of your gem’s #require_path.

Plugins may add commands to *3scale* CLI or may add *subcommands* to any existing command.
Subcommands may be added to main commands or other subcommands as children.

Nothing better than few examples to illustrate .

Let's create a plugin to add a main `simple hello world` command.

```
$ cat lib/3scale_toolbox_plugin.rb
require '3scale_toolbox/cli'

module FooCommand
  extend ThreeScaleToolbox::Command

  def self.command
    Cri::Command.define do
      name        'foo'
      usage       'foo [options]'
      summary     '3scale foo'
      description '3scale foo command'
      flag :h, :help, 'show help for this command' do |_, cmd|
        puts cmd.help
        exit 0
      end
      run do |opts, args, _|
        puts "foo done"
      end
    end
  end
end
ThreeScaleToolbox::CLI.add_command(FooCommand)

$ RUBYOPT=-Ilib 3scale foo
Hello World
```
Few things worth to highlight.
- Your module must be extended by *ThreeScaleToolbox::Command* module. It allows your command to be added to CLI command tree.
- Must implement `command` module function and return instance of `Cri::Command` from [cri](https://github.com/ddfreyne/cri)
- Add your command to `3scale` CLI command tree by calling `ThreeScaleToolbox::CLI.add_command`

Your plugin help is also available using builtin *help* command

```
$ RUBYOPT=-Ilib 3scale help foo
NAME
    foo - foo command

USAGE
    3scale foo [options]

DESCRIPTION
    This command does a lot of stuff.

OPTIONS
    -h --help         show help for this command

OPTIONS FOR 3SCALE
    -v --version      Prints the version of this command
```

Let's create a plugin to add a `simple hello world` subcommand for the builtin *copy* command.

```
$ cat lib/3scale_toolbox_plugin.rb
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/copy_command'

module FooCommand
  extend ThreeScaleToolbox::Command

  def self.command
    Cri::Command.define do
      name        'foo'
      usage       'foo [options]'
      summary     '3scale copy foo'
      description '3scale copy foo subcommand'
      flag :h, :help, 'show help for this command' do |_, cmd|
        puts cmd.help
        exit 0
      end
      run do |opts, args, _|
        puts "foo done"
      end
    end
  end
end

ThreeScaleToolbox::Commands::CopyCommand.add_subcommand(FooCommand)

$ RUBYOPT=-Ilib 3scale copy foo
foo done
```

Few things worth to highlight.
- Your module must be extended by *ThreeScaleToolbox::Command* module. It allows your command to be added to CLI command tree.
- Must implement `command` module function and return instance of `Cri::Command` from [cri](https://github.com/ddfreyne/cri)
- Add your subcommand to `3scale` CLI command tree by calling parent command's module's `add_subcommand` method.

Checking `copy` command help, it can be verified the new subcommand `foo` is added.

```
$ RUBYOPT=-Ilib 3scale help copy
NAME
    copy - 3scale CLI copy

USAGE
    3scale copy <command> [options]

DESCRIPTION
    3scale CLI copy tools to manage your API from the terminal.

SUBCOMMANDS
    foo         3scale copy foo
    service     3scale CLI copy service

OPTIONS
    -h --help         show help for this command

OPTIONS FOR 3SCALE
    -v --version      Prints the version of this command
```

Now, package your plugin as a [gem](https://guides.rubygems.org/make-your-own-gem/) and let us know about it.

## Existing Plugins
