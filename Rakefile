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

task default: 'spec:all'
