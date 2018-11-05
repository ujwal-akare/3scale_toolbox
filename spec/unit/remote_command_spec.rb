require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::RemoteCommand::RemoteCommand do
  include_context :temp_dir
  include_context :resources

  context '#run' do
    let(:config_file) { File.join(tmp_dir, '.3scalerc') }
    let(:options) { { 'config-file': config_file } }
    subject { described_class.new(options, nil, nil) }

    context 'config file does not exist' do
      let(:config_file) { File.join(tmp_dir, 'non_existing_file') }

      it 'reports empty remote list' do
        expect { subject.run }.to output(/Empty remote list/).to_stdout
      end
    end

    context 'config file has invalid data' do
      context 'data is not valid yaml' do
        before :each do
          File.open(config_file, 'w') { |f| f.write('<tag1>somedata</tag1>') }
        end

        it 'raises error' do
          expect { subject.run }.to raise_error(PStore::Error)
        end
      end

      context 'data lacks remote attrs' do
        before :each do
          File.open(config_file, 'w') do |f|
            f.write(<<~AUTHENTICATION_KEY_MISSING)
              ---
              :remotes:
                ecorp:
                  :endpoint: https://e-corporation-admin.amp24.127.0.0.1.nip.io
            AUTHENTICATION_KEY_MISSING
          end
        end

        it 'raises error' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /invalid remote/)
        end
      end
    end

    # test with N remotes, check N lines
    context 'config file has valid data' do
      let(:n_remotes) { 5 }
      let(:config_file) { File.join(resources_path, 'valid_config_file.yaml') }

      it 'reports all remotes' do
        # match number of lines
        expect { subject.run }.to output(/(.*\n){#{n_remotes}}/).to_stdout
        remote_output_pattern = /(?x)(^remote_[1-#{n_remotes}]
                               [[:blank:]]
                               https:\/\/[1-#{n_remotes}]\S*
                               [[:blank:]]
                               [1-#{n_remotes}]
                               \n){#{n_remotes}}/
        expect { subject.run }.to output(remote_output_pattern).to_stdout
      end
    end
  end
end
