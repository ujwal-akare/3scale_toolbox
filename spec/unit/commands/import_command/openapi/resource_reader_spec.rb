require '3scale_toolbox'

RSpec.shared_examples 'parsed content' do
  let(:result) { subject.openapi_resource(resource) }

  it 'does not return nil' do
    expect(result).not_to be_nil
    expect(result.size).to eq(2)
  end

  it 'is read' do
    expect(result[0]).to eq(content)
  end

  it 'has correct format' do
    expect(result[1]).to include(expected_format)
  end
end

RSpec.describe 'OpenAPI ResourceReader' do
  include_context :temp_dir

  context '#openapi_resource' do
    subject do
      Class.new { include ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ResourceReader }.new
    end

    let(:content) do
      <<~YAML
        ---
        swagger: "2.0"
      YAML
    end

    context 'from file' do
      let(:resource) { tmp_dir.join('petstore.yaml').tap { |conf| conf.write(content) } }
      let(:expected_format) { { format: '.yaml' } }
      it_behaves_like 'parsed content'
    end

    context 'from URL' do
      let(:resource) { 'https://example.com/petstore.yaml' }
      let(:expected_format) { { format: '.yaml' } }

      before :each do
        net_class_stub = class_double(Net::HTTP).as_stubbed_const
        expect(net_class_stub).to receive(:get).and_return(content)
      end

      it_behaves_like 'parsed content'
    end

    context 'from stdin' do
      let(:resource) { '-' }
      let(:expected_format) { { format: :yaml } }

      before :each do
        expect(STDIN).to receive(:read).and_return(content)
      end

      it_behaves_like 'parsed content'
    end
  end
end
