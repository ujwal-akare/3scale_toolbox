require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::RemoteCommand::RemoteRenameSubcommand do
  include_context :resources
  include_context :temp_dir

  context '#run' do
    let(:config_file) { File.join(tmp_dir, '.3scalerc') }
    let(:options) { { 'config-file': config_file } }
    let(:arguments) { { remote_old_name: 'some_remote', remote_new_name: 'new_remote' } }
    subject { described_class.new(options, arguments, nil) }
    let(:configuration) { ThreeScaleToolbox::Configuration.new(config_file) }

    context 'old remote name does not exist' do
      context 'empty config file' do
        it 'raises error' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /old name 'some_remote' does not exist/)
        end
      end

      context 'old remote not in available remotes' do
        let(:config_file) { File.join(tmp_dir, 'valid_config_file.yaml') }
        before :each do
          FileUtils.cp(File.join(resources_path, 'valid_config_file.yaml'),
                       tmp_dir)
        end

        it 'raises error' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /old name 'some_remote' does not exist/)
          expect(configuration.data(:remotes)).to include('remote_1')
        end
      end
    end

    context 'new remote name already exists' do
      let(:config_file) { File.join(tmp_dir, 'valid_config_file.yaml') }
      before :each do
        FileUtils.cp(File.join(resources_path, 'valid_config_file.yaml'),
                     tmp_dir)
      end
      let(:arguments) { { remote_old_name: 'remote_1', remote_new_name: 'remote_2' } }

      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /new name 'remote_2' already exists/)
      end
    end

    context 'valid rename command' do
      let(:config_file) { File.join(tmp_dir, 'valid_config_file.yaml') }
      before :each do
        # Config file is going to be updated.
        # Config file will be a fresh copy of the source
        FileUtils.cp(File.join(resources_path, 'valid_config_file.yaml'),
                     tmp_dir)
      end
      let(:arguments) { { remote_old_name: 'remote_3', remote_new_name: 'remote_new' } }

      it 'old remote name is gone' do
        subject.run
        expect(configuration.data(:remotes)).not_to include('remote_3')
      end

      it 'new remote exists' do
        subject.run
        expected_remote_value = { endpoint: 'https://3.example.com',
                                  provider_key: '3' }
        expect(configuration.data(:remotes)).to include('remote_new' => expected_remote_value)
      end
    end
  end
end
