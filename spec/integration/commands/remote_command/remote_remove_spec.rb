RSpec.describe ThreeScaleToolbox::Commands::RemoteCommand::RemoteRemoveSubcommand do
  include_context :resources
  include_context :temp_dir

  context '#run' do
    let(:config_file) { File.join(tmp_dir, '.3scalerc') }
    let(:options) { { 'config-file': config_file } }
    let(:arguments) { {} }
    subject { described_class.new(options, arguments, nil) }
    let(:configuration) { ThreeScaleToolbox::Configuration.new(config_file) }

    context 'remote does not exist' do
      let(:arguments) { { remote_name: 'some_remote' } }

      it 'raises error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /could not remove remote/)
      end
    end

    context 'remote exists' do
      let(:config_file) { File.join(tmp_dir, 'valid_config_file.yaml') }
      let(:arguments) { { remote_name: 'remote_1' } }
      before :each do
        # Config file is going to be updated.
        # Config file will be a fresh copy of the source
        FileUtils.cp(File.join(resources_path, 'valid_config_file.yaml'),
                     tmp_dir)
      end

      it 'after removing is gone' do
        subject.run
        expect(configuration.data(:remotes)).not_to include('remote_1')
      end

      it 'after removing, other remotes still in conf file' do
        subject.run
        2.upto(5) do |i|
          expect(configuration.data(:remotes)).to include("remote_#{i}")
        end
      end
    end
  end
end
