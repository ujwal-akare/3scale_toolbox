RSpec.describe ThreeScaleToolbox::Configuration do
  include_context :temp_dir

  let(:config_file) { File.join(tmp_dir, '.3scalerc') }
  subject { described_class.new config_file }

  context '#data' do
    context 'non existing file' do
      let(:config_file) { File.join(tmp_dir, 'non_existing_file') }

      it 'returns nothing' do
        expect(subject.data(:some_key)).to be_nil
      end
    end

    context 'empty file' do
      before :each do
        File.open(config_file, 'w') {}
      end

      it 'returns nothing' do
        expect(subject.data(:some_key)).to be_nil
      end
    end

    context 'invalid data' do
      before :each do
        File.open(config_file, 'w') { |f| f.write('<tag1>somedata</tag1>') }
      end
      it 'raises error' do
        expect { subject.data(:some_key) }.to raise_error(PStore::Error)
      end
    end

    context 'valid data' do
      before :each do
        config = described_class.new config_file
        config.update(:some_key) { 'some_data' }
      end

      it 'finds on key' do
        expect(subject.data(:some_key)).to eq('some_data')
      end

      it 'nil on wrong key' do
        expect(subject.data(:wrong_key)).to be_nil
      end
    end
  end

  context '#update' do
    context 'file with data' do
      before :each do
        config = described_class.new config_file
        config.update(:some_key) { 'some_data' }
      end

      it 'updates gets persisted' do
        expect(subject.data(:some_key)).to eq('some_data')
        subject.update(:some_key) { 'other_data' }
        expect(subject.data(:some_key)).to eq('other_data')
        expect(described_class.new(config_file).data(:some_key)).to eq('other_data')
      end
    end
  end
end
