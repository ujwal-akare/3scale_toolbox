RSpec.describe 'openapi command step'  do
  class OpenAPIStepClass
    include ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::Step

    attr_reader :context

    def initialize(context)
      @context = context
    end
  end

  let(:api_spec) do
    instance_double(ThreeScaleToolbox::OpenAPI::OAS3, 'api_spec')
  end

  context '#operations' do
    let(:context) do
      {
        api_spec: api_spec,
        prefix_matching: false
      }
    end

    let(:operations) do
      [
        { path: '/mypath', verb: 'delete', operation_id: 'someOp', description: 'someDescr' }
      ]
    end
    subject { OpenAPIStepClass.new(context).operations }

    before :example do
      allow(api_spec).to receive(:base_path).and_return('/v1')
      allow(api_spec).to receive(:operations).and_return(operations)
    end

    it 'available' do
      is_expected.not_to be_nil
    end

    it 'parsed as not empty' do
      is_expected.not_to be_empty
    end

    it 'parsed type' do
      expect(subject[0]).to be_a(ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::Operation)
    end

    it 'contains expected data' do
      expect(subject[0].operation[:base_path]).to eq('/v1')
      expect(subject[0].operation[:public_base_path]).to eq('/v1')
      expect(subject[0].operation[:path]).to eq('/mypath')
      expect(subject[0].operation[:verb]).to eq('delete')
      expect(subject[0].operation[:operationId]).to eq('someOp')
      expect(subject[0].operation[:description]).to eq('someDescr')
      expect(subject[0].operation[:prefix_matching]).to eq(false)
    end
  end

  context '#base_path' do
    subject { OpenAPIStepClass.new(context).base_path }
    let(:context) { { api_spec: api_spec } }

    context 'base path is not found' do
      before :example do
        expect(api_spec).to receive(:base_path).and_return(nil)
      end

      it 'is path root' do
        is_expected.to eq('/')
      end
    end

    context 'base path exists' do
      before :example do
        expect(api_spec).to receive(:base_path).and_return('/someBasePath')
      end

      it 'matches' do
        is_expected.to eq('/someBasePath')
      end
    end
  end

  context '#public_base_path' do
    subject { OpenAPIStepClass.new(context).public_base_path }
    let(:override_public_basepath) { nil }
    let(:context) { { api_spec: api_spec, override_public_basepath: override_public_basepath } }

    before :example do
      allow(api_spec).to receive(:base_path).and_return('/someBasePath')
    end

    it 'when not overriden, base path' do
      is_expected.to eq('/someBasePath')
    end

    context 'overriden' do
      let(:override_public_basepath) { '/overriden/path' }

      it 'matches overriden' do
        is_expected.to eq('/overriden/path')
      end
    end
  end
end
