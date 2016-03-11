require 'optparse'

module ThreeScaleToolbox
  module CLI
    Options = Struct.new(:command)

    class Parser
      def self.parse(options)
        args = Options.new(nil)

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: 3scale <command> [options]"


          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
        end

        begin
          opt_parser.order!(options)
        rescue OptionParser::InvalidOption => e
          p e
        end

        return args
      end
    end

    def self.parse(argv = ARGV)
      options = Parser.parse(argv)
      options.command = argv.shift
      options.command = subcommands.find { |subcommand| subcommand.name == options.command }

      [ options, argv ]
    end

    def self.print_help!
      Parser.parse %w[--help]
    end

    def self.plugins
      Gem.loaded_specs.select{ |name, _| name.start_with?('3scale') }.values
    end

    def self.current_command
      File.expand_path($0, Dir.pwd)
    end

    def self.subcommands
      plugins
          .flat_map { |spec| spec.executables.flat_map{ |bin| Subcommand.new(bin, spec) } }
          .reject { |subcommand| subcommand.full_path == current_command || subcommand.name.nil? }
    end

    class Subcommand
      attr_reader :executable, :spec

      def initialize(executable, spec)
        @executable = executable
        @spec = spec
      end

      def to_s
        name
      end

      def name
        executable.split('-', 2)[1]
      end

      def full_path
        spec.bin_file(executable)
      end
    end
  end
end
