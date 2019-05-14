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

  context '#plugin_paths' do
    it 'finds plugin' do
      expect(described_class.plugin_paths).to include(dest_plugin_file.to_s)
    end
  end

  context '#load_plugins' do
    it 'loads plugin' do
      expect { described_class.load_plugins }.not_to raise_error
      expect(Object.const_get(name.capitalize.to_sym)).to be_truthy
    end
  end

  context '#default_config_file' do
    it 'using ENV var' do
      filename = 'some_file_name'
      env_copy = ENV.to_h
      env_copy['THREESCALE_CLI_CONFIG'] = filename
      stub_const('ENV', env_copy)
      expect(described_class.default_config_file).to eq filename
    end

    it 'default' do
      expect(described_class.default_config_file).to eq File.join Gem.user_home, '.3scalerc.yaml'
    end
  end
end
