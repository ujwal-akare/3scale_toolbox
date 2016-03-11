require 'optparse'

module ThreeScaleToolbox
  module CLI
    Options = Struct.new(:name)

    class Parser
      def self.parse(options)
        args = Options.new('command')

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: 3scale command [options]"


          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
        end

        opt_parser.parse!(options)

        return args
      end
    end

    def self.help
      Parser.parse %w[--help]
    end
  end
end
