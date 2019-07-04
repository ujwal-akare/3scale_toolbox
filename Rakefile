require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  namespace :spec do
    RSpec::Core::RakeTask.new(:integration) do |t|
      t.pattern = 'spec/integration/**/*_spec.rb'
    end
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = 'spec/unit/**/*_spec.rb'
    end
    RSpec::Core::RakeTask.new(:all) do |t|
      t.pattern = 'spec/**/*_spec.rb'
    end
  end
rescue LoadError
  warn 'RSpec is not installed!'
end

namespace :license_finder do
  DECISION_FILE = "#{File.dirname(__FILE__)}/.dependency_decisions.yml".freeze

  desc 'Check license compliance of dependencies'
  task :check do
    STDOUT.puts "Checking license compliance\n"
    unless system("license_finder --decisions-file=#{DECISION_FILE}")
      STDERR.puts "\n*** License compliance test failed  ***\n"
      exit 1
    end
  end

  desc 'Generate an CSV report for licenses'
  task :report do
    system("license_finder report --decisions-file=#{DECISION_FILE} --quiet --format=xml")
  end
end

task default: 'spec:unit'
