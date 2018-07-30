require 'fileutils'
require 'shared_contexts'
require '3scale_toolbox/cli'

RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

RSpec.describe 'Plugin command' do
  include_context :temp_dir

  before(:each) do
    $LOAD_PATH.unshift(tmp_dir) unless $LOAD_PATH.include?(tmp_dir)
  end

  after(:each) do
    $LOAD_PATH.delete(tmp_dir)
  end

  it 'is not loaded when not in load path' do
    expect do
      ThreeScaleToolbox::CLI.run(%w[simple])
    end.to raise_error.and output(/unknown command/).to_stderr
  end

  it 'is loaded when expected' do
    plugin_file = File.join(File.dirname(__FILE__), 'resources', '3scale_toolbox_plugin_simple.rb')
    FileUtils.cp plugin_file, File.join(tmp_dir, '3scale_toolbox_plugin.rb')

    expect do
      ThreeScaleToolbox::CLI.run(%w[simple])
    end.to not_raise_error.and output("this is simple command\n").to_stdout
  end
end
