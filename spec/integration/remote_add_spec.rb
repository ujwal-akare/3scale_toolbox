RSpec.describe ThreeScaleToolbox::Commands::RemoteCommand::RemoteAddSubcommand do
  include_context :resources
  include_context :temp_dir

  context '#run' do
    let(:config_file) { File.join(tmp_dir, '.3scalerc') }
    let(:options) { { 'config-file': config_file } }
    let(:arguments) { {} }
    subject { described_class.new(options, arguments, nil) }

    context 'remote name already exists' do
      let(:config_file) { File.join(resources_path, 'valid_config_file.yaml') }
      let(:arguments) do
        { remote_name: 'remote_1', remote_url: 'https://1@example.com' }
      end

      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /remote name already exists/)
      end
    end

    context 'remote url not valid' do
      let(:arguments) do
        { remote_name: 'remote_1', remote_url: 'https://1@example.com' }
      end
      before :each do
        stub_request(:get, /example.com/).to_return(status: 403,
                                                    body: 'Forbidden')
      end

      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /remote not valid/)
      end
    end

    context 'remote url is not http' do
      let(:arguments) do
        { remote_name: 'remote_1', remote_url: 'some_name' }
      end

      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::InvalidUrlError)
      end
    end

    context 'remote is valid' do
      let(:config_file) { File.join(tmp_dir, 'valid_config_file.yaml') }
      let(:arguments) do
        { remote_name: 'remote_new', remote_url: 'https://new@example.com' }
      end
      before :each do
        # Config file is going to be updated.
        # Config file will be a fresh copy of the source
        FileUtils.cp(File.join(resources_path, 'valid_config_file.yaml'),
                     tmp_dir)
        stub_request(:get, /example.com/).to_return(status: 200,
                                                    body: '{"accounts": []}')
      end
      let(:configuration) { ThreeScaleToolbox::Configuration.new(config_file) }

      it 'new remote is stored in conf file' do
        subject.run
        expected_remote_value = { endpoint: 'https://example.com',
                                  authentication: 'new' }
        expect(configuration.data(:remotes)).to include('remote_new' => expected_remote_value)
      end

      it 'old remotes still in conf file' do
        subject.run
        1.upto(5) do |i|
          expect(configuration.data(:remotes)).to include("remote_#{i}")
        end
      end
    end
  end
end
