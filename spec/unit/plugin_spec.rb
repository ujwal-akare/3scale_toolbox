require '3scale_toolbox/cli'

RSpec.describe 'Plugin command' do
  include_context :temp_dir
  include_context :plugin
  include_context :random_name

  around(:each) do |example|
    $LOAD_PATH.unshift(tmp_dir) unless $LOAD_PATH.include?(tmp_dir)
    example.run
    $LOAD_PATH.delete(tmp_dir)
  end

  it 'is not loaded when not in load path' do
    expect do
      ThreeScaleToolbox::CLI.run(%w[simple])
    end.to raise_error(SystemExit).and output(/unknown command/).to_stderr
  end

  it 'is loaded when expected' do
    name = random_lowercase_name
    plugin = get_plugin_content(name.capitalize, name)
    File.open(File.join(tmp_dir, '3scale_toolbox_plugin.rb'), 'w') do |file|
      file.write(plugin)
    end

    expect do
      ThreeScaleToolbox::CLI.run([name])
    end.to output("this is #{name} command\n").to_stdout
  end
end
