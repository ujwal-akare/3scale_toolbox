require '3scale_toolbox/configuration'

module ThreeScaleToolbox

  def self.load_plugins
    plugin_paths.each { |plugin_path| require plugin_path }
  end

  def self.plugin_paths
    Gem.find_files('3scale_toolbox_plugin')
  end

  def self.default_config_file
    # THREESCALE_CLI_CONFIG env var has priority over $HOME/.3scalerc.yaml file
    ENV['THREESCALE_CLI_CONFIG'] || File.join(Gem.user_home, '.3scalerc.yaml')
  end
end
