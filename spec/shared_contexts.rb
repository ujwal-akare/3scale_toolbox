require 'tmpdir'

RSpec.shared_context :temp_dir do
  around(:each) do |example|
    Dir.mktmpdir('3scale_toolbox_rspec-') do |dir|
      @tmp_dir = dir
      example.run
    end
  end

  attr_reader :tmp_dir
end
