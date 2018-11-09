module ThreeScaleToolbox::CLI
  # Catches errors and prints nice diagnostic messages
  class ErrorHandler
    def self.error_watchdog(exit_on_error: true)
      new.error_watchdog(exit_on_error: exit_on_error) { yield }
    end

    def error_watchdog(exit_on_error:)
      # Set exit handler
      %w[INT TERM].each do |signal|
        Signal.trap(signal) do
          puts
          exit!(0)
        end
      end

      # Set stack trace dump handler
      if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'jruby'
        begin
          Signal.trap('USR1') do
            puts 'Caught USR1; dumping a stack trace'
            puts caller.map { |i| "  #{i}" }.join("\n")
          end
        rescue ArgumentError
        end
      end

      # Run
      yield
    rescue StandardError, ScriptError => e
      handle_error(e, exit_on_error: exit_on_error)
    end

    private

    def handle_error(error, exit_on_error:)
      if expected_error?(error)
        warn
        warn "Error: #{error.message}"
      else
        print_error(error)
      end
      exit(1) if exit_on_error
    end

    def expected_error?(error)
      case error
      when ThreeScaleToolbox::Error
        true
      else
        false
      end
    end

    def print_error(error)
      write_error(error, $stderr)

      File.open('crash.log', 'w') do |io|
        write_verbose_error(error, io)
      end

      write_section_header($stderr, 'Detailed information')
      warn
      warn 'A detailed crash log has been written to ./crash.log.'
    end

    def write_error(error, stream)
      write_error_message(error, stream)
      write_stack_trace(error, stream)
    end

    def write_error_message(error, stream)
      write_section_header(stream, 'Message')
      stream.puts "\e[1m\e[31m#{error.class}: #{error.message}\e[0m"
    end

    def write_stack_trace(error, stream)
      write_section_header(stream, 'Backtrace')
      stream.puts error.backtrace
    end

    def write_version_information(stream)
      write_section_header(stream, 'Version Information')
      stream.puts ThreeScaleToolbox::VERSION
    end

    def write_system_information(stream)
      write_section_header(stream, 'System Information')
      stream.puts `uname -a`
    end

    def write_installed_gems(stream)
      write_section_header(stream, 'Installed gems')
      gems_and_versions.each do |g|
        stream.puts "  #{g.first} #{g.last.join(', ')}"
      end
    end

    def write_load_paths(stream)
      write_section_header(stream, 'Load paths')
      $LOAD_PATH.each_with_index do |i, index|
        stream.puts "  #{index}. #{i}"
      end
    end

    def write_verbose_error(error, stream)
      stream.puts "Crashlog created at #{Time.now}"

      write_error_message(error, stream)
      write_stack_trace(error, stream)
      write_version_information(stream)
      write_system_information(stream)
      write_installed_gems(stream)
      write_load_paths(stream)
    end

    def gems_and_versions
      gems = {}
      Gem::Specification.find_all.sort_by { |s| [s.name, s.version] }.each do |spec|
        gems[spec.name] ||= []
        gems[spec.name] << spec.version.to_s
      end
      gems
    end

    def write_section_header(stream, title)
      stream.puts

      stream.puts "===== #{title.upcase}:"
      stream.puts
    end
  end
end
