require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox do
  include_context :temp_dir
  include_context :plugin
  include_context :random_name

  let(:name) { random_lowercase_name }
  let(:dest_plugin_file) { tmp_dir.join('3scale_toolbox_plugin.rb') }

  around(:each) do |example|
    plugin = get_plugin_content(name.capitalize, name)
    dest_plugin_file.write(plugin)
    $LOAD_PATH.unshift(tmp_dir) unless $LOAD_PATH.include?(tmp_dir)
    example.run
    $LOAD_PATH.delete(tmp_dir)
  end

  it '.plugin_paths finds plugin' do
    expect(described_class.plugin_paths).to include(dest_plugin_file.to_s)
  end

  it '.load_plugins loads plugin' do
    expect { described_class.load_plugins }.not_to raise_error
    expect(Object.const_get(name.capitalize.to_sym)).to be_a_kind_of(ThreeScaleToolbox::Command)
  end
end
