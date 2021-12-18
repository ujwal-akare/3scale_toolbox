RSpec.shared_examples 'content is read' do
  let(:result) { subject.read_content(resource) }

  it 'does not return nil' do
    expect(result).not_to be_nil
  end

  it 'is read' do
    expect(result).to eq(content)
  end
end

RSpec.describe ThreeScaleToolbox::ResourceReader do
  include_context :temp_dir

  subject do
    Class.new { include ThreeScaleToolbox::ResourceReader }.new
  end

  context '#load_resource' do
    let(:resource) { tmp_dir.join('file.ext').tap { |conf| conf.write(content) } }
    let(:result) { subject.load_resource(resource) }

    context 'valid json' do
      let(:content) { '{ "some_key": "some value" }' }

      it 'does not return nil' do
        expect(result).not_to be_nil
      end

      it 'is loaded' do
        expect(result).to eq('some_key' => 'some value')
      end
    end

    context 'valid yaml' do
      let(:content) do
        <<~YAML
          ---
          some_key: "some value"
        YAML
      end

      it 'does not return nil' do
        expect(result).not_to be_nil
      end

      it 'is loaded' do
        expect(result).to eq('some_key' => 'some value')
      end
    end

    context 'invalid yaml' do
      let(:content) do
        <<~YAML
          ---
          `
        YAML
      end

      it 'raises error' do
        expect { result }.to raise_error(ThreeScaleToolbox::Error)
      end
    end

    context 'invalid json' do
      let(:content) { '{ `some }' }

      it 'raises error' do
        expect { result }.to raise_error(ThreeScaleToolbox::Error)
      end
    end
  end

  context '#read_content' do
    let(:content) do
      <<~YAML
        ---
        swagger: "2.0"
      YAML
    end

    context 'from file' do
      let(:resource) { tmp_dir.join('file.yaml').tap { |conf| conf.write(content) } }
      it_behaves_like 'content is read'
    end

    context 'from folder' do
      let(:resource) { tmp_dir }

      it 'error is raised' do
        expect { subject.read_content(resource) }.to raise_error(ThreeScaleToolbox::Error,
                                                                 /File not found/)
      end
    end

    context 'from URL' do
      let(:resource) { 'https://example.com/petstore.yaml' }

      before :each do
        net_class_stub = class_double(Net::HTTP).as_stubbed_const
        expect(net_class_stub).to receive(:get).and_return(content)
      end

      it_behaves_like 'content is read'
    end

    context 'from stdin' do
      let(:resource) { '-' }

      before :each do
        expect(STDIN).to receive(:read).and_return(content)
      end

      it_behaves_like 'content is read'
    end

    context 'from stringio' do
      let(:resource) { StringIO.new content }
      it_behaves_like 'content is read'
    end
  end
end
