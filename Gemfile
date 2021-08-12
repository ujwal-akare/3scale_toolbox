source 'https://rubygems.org'

# Specify your gem's dependencies in 3scale.gemspec
gemspec

group :development do
  gem 'license_finder', '~> 5.11'
  # Thor is a transitive dependency from license_finder
  # Latest Thor 1.1.0 breaks license_finder report command.
  # with Thor 1.1.0, the license_finder report command's --quiet flag to silence the progress
  # alse silences the report itself, which is unexpected.
  # license_finder report --decisions-file=#{DECISION_FILE} --quiet --format=xml
  gem 'thor', '1.0.1'
  gem 'pry'
  # rubyzip is a transitive depencency from license_finder with vulnerability on < 1.3.0
  gem 'rubyzip', '>= 1.3.0'
end

group :test do
  gem 'codecov', require: false
end
