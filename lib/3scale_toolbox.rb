module ThreeScaleToolbox
  def self.load_plugins
    plugin_paths.each { |plugin_path| require plugin_path }
  end

  def self.plugin_paths
    Gem.find_files('3scale_toolbox_plugin')
  end
end
