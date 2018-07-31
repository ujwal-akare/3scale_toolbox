require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox do
  include_context :temp_dir
  include_context :plugin
  include_context :random_name

  let(:name) { random_lowercase_name }
  let(:dest_plugin_file) { File.join(tmp_dir, '3scale_toolbox_plugin.rb') }

  before(:each) do
    plugin = get_plugin_content(name.capitalize, name)
    File.open(dest_plugin_file, 'w') do |file|
      file.write(plugin)
    end
    $LOAD_PATH.unshift(tmp_dir) unless $LOAD_PATH.include?(tmp_dir)
  end

  after(:each) do
    $LOAD_PATH.delete(tmp_dir)
  end

  it '.plugin_paths finds plugin' do
    expect(described_class.plugin_paths).to include(dest_plugin_file)
  end

  it '.load_plugins loads plugin' do
    expect { described_class.load_plugins }.not_to raise_error
    expect(Object.const_get(name.capitalize.to_sym)).not_to be_nil
  end
end
