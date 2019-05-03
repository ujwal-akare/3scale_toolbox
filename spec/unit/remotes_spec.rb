RSpec.describe ThreeScaleToolbox::Remotes do
  include_context :resources
  include_context :temp_dir

  RSpec.shared_examples 'raises invalid url error' do
    it 'raises error' do
      expect { subject.add_uri('some_name', origin) }.to raise_error(ThreeScaleToolbox::InvalidUrlError,
                                                                     /invalid url/)
    end
  end

  let(:yaml_content) do
    <<~YAML
      ---
        :remotes:
          remote_1:
            :endpoint: https://1.example.com
            :authentication: '123456789'
    YAML
  end
  let(:config_file) { tmp_dir.join('.3scalerc').tap { |conf| conf.write(yaml_content) } }
  let(:config) { ThreeScaleToolbox::Configuration.new(config_file) }
  let(:endpoint) { 'https://1.example.com' }
  let(:authentication) { '123456789' }
  let(:verify_ssl) { true }
  let(:origin) do
    u = URI(endpoint)
    u.user = authentication
    u.to_s
  end
  let(:remote_info) { { endpoint: endpoint, authentication: authentication } }

  subject { described_class.new(config) }

  context '#all' do
    context 'valid yaml, invalid remote' do
      let(:yaml_content) do
        <<~YAML
          ---
          :remotes:
            remote_1:
              :bla: https://1.example.com
              :boo: '1'
        YAML
      end

      it 'raises invalid error' do
        expect { subject.all }.to raise_error(ThreeScaleToolbox::Error,
                                              /invalid remote configuration/)
      end
    end

    context 'valid conf file' do
      let(:config_file) { File.join(resources_path, 'valid_config_file.yaml') }

      it '5 remotes available' do
        expect(subject.all.size).to eq(5)
      end

      it 'remote 3 available' do
        expect(subject.all).to include('remote_3' => { endpoint: 'https://3.example.com',
                                                       authentication: '3' })
      end
    end
  end

  context '#add_uri' do
    context '"htt://bla"' do
      let(:origin) { 'htt://bla' }

      it_behaves_like 'raises invalid url error'
    end

    context '"httpss://bla"' do
      let(:origin) { 'htt://bla' }

      it_behaves_like 'raises invalid url error'
    end

    context '"invalid"' do
      let(:origin) { 'invalid' }

      it_behaves_like 'raises invalid url error'
    end

    context 'valid url' do
      it 'is added' do
        subject.add_uri('some_name', origin)
        expect(config.data(:remotes)).to include('some_name' => remote_info)
      end
    end
  end

  context '#add' do
    context 'invalid remote' do
      let(:remote_info) { { jdjd: 'kdkd' } }
      it 'raises error' do
        expect { subject.add('some_name', remote_info) }.to raise_error(ThreeScaleToolbox::Error,
                                                                        /invalid remote configuration/)
      end
    end

    context 'valid remote' do
      it 'is added' do
        subject.add('some_name', remote_info)
        expect(config.data(:remotes)).to include('some_name' => remote_info)
      end
    end
  end

  context '#delete' do
    context 'existing remote' do
      it 'remote is gone' do
        expect(config.data(:remotes)).to include('remote_1' => remote_info)
        expect(subject.delete('remote_1')).to eq(remote_info)
        expect(config.data(:remotes)).not_to include('some_name' => remote_info)
      end
    end

    context 'non existing remote' do
      let(:myobj) { double('myobj') }

      it 'returns nil' do
        expect(config.data(:remotes)).not_to include('some_name')
        expect(subject.delete('some_name')).to be_nil
      end

      it 'when block given, runs block' do
        expect(config.data(:remotes)).not_to include('some_name')
        expect(myobj).to receive(:called).with('some_name').and_return('some_value')
        expect(subject.delete('some_name') { |el| myobj.called(el) }).to eq('some_value')
      end
    end
  end

  context '#fetch' do
    context 'existing remote' do
      it 'remote is returned' do
        expect(config.data(:remotes)).to include('remote_1' => remote_info)
        expect(subject.fetch('remote_1')).to eq(remote_info)
      end
    end

    context 'non existing remote' do
      it 'raises error' do
        expect(config.data(:remotes)).not_to include('some_name')
        expect { subject.fetch('some_name') }.to raise_error(KeyError)
      end
    end
  end
end
