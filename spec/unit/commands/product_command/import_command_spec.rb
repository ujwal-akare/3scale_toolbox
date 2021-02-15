RSpec.describe ThreeScaleToolbox::Commands::ProductCommand::ImportSubcommand do
  include_context :temp_dir

  let(:source_content) { '' }
  let(:resource) { tmp_dir.join('file.yaml').tap { |f| f.write(source_content) } }
  let(:remote) { 'https://1234556@3scale-admin.source.example.com' }
  let(:remote_obj) { instance_double(ThreeScale::API::Client, 'remote_obj') }
  let(:product_crd_class) { class_double(ThreeScaleToolbox::CRD::ProductParser).as_stubbed_const }
  let(:backend_crd_class) { class_double(ThreeScaleToolbox::CRD::BackendParser).as_stubbed_const }
  let(:remote_crd_class) { class_double(ThreeScaleToolbox::CRD::Remote).as_stubbed_const }
  let(:product_copy_class) { class_double(ThreeScaleToolbox::Commands::ProductCommand::CopySubcommand).as_stubbed_const }
  let(:remote_crd) { instance_double(ThreeScaleToolbox::CRD::Remote) }
  let(:product_cr_parser) { instance_double(ThreeScaleToolbox::CRD::ProductParser) }
  let(:backend_cr_parser) { instance_double(ThreeScaleToolbox::CRD::BackendParser) }
  let(:arguments) { { remote: remote } }
  let(:options) { { file: resource.realpath } }

  subject { described_class.new(options, arguments, nil) }

  before :each do
    allow(subject).to receive(:threescale_client).with(remote).and_return(remote_obj)
  end

  context '#run' do
    context 'on missing api version field' do
      let(:source_content) do
        <<~YAML
          ---
          wrrrrong: v1
          kind: List
          items: []
        YAML
      end

      it 'raise error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /apiVersion not found/)
      end
    end

    context 'on invalid api version value' do
      let(:source_content) do
        <<~YAML
          ---
          apiVersion: wrongvalue
          kind: List
          items: []
        YAML
      end

      it 'raise error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /apiVersion wrong value/)
      end
    end

    context 'on invalid kind value' do
      let(:source_content) do
        <<~YAML
          ---
          apiVersion: v1
          kind: jdjd
          items: []
        YAML
      end

      it 'raise error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /kind wrong value/)
      end
    end

    context 'on missing items field' do
      let(:source_content) do
        <<~YAML
          ---
          apiVersion: v1
          kind: List
        YAML
      end

      it 'raise error' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /items not found/)
      end
    end

    context 'empty item list' do
      let(:source_content) do
        <<~YAML
          ---
          apiVersion: v1
          kind: List
          items: []
        YAML
      end

      it 'no op' do
        subject.run
      end
    end

    context 'when product exists' do
      let(:expected_product) do
        {
          'apiVersion' => 'capabilities.3scale.net/v1beta1', 'kind' => 'Product', 'spec' => {}
        }
      end
      let(:expected_backend) do
        {
          'apiVersion' => 'capabilities.3scale.net/v1beta1', 'kind' => 'Backend', 'spec' => {}
        }
      end
      let(:expected_product_list) { [product_cr_parser] }
      let(:expected_backend_list) { [backend_cr_parser] }
      let(:expected_context) { {} }


      before :example do
        allow(product_cr_parser).to receive(:system_name).and_return('product_a')
        allow(backend_cr_parser).to receive(:system_name).and_return('backend_a')
        expect(remote_crd_class).to receive(:new).with(expected_product_list, expected_backend_list).and_return(remote_crd)
        expect(product_crd_class).to receive(:new).with(expected_product).and_return(product_cr_parser)
        expect(backend_crd_class).to receive(:new).with(expected_backend).and_return(backend_cr_parser)
      end

      let(:source_content) do
        <<~YAML
          ---
          apiVersion: v1
          kind: List
          items:
            - apiVersion: capabilities.3scale.net/v1beta1
              kind: Product
              spec: {}
            - apiVersion: capabilities.3scale.net/v1beta1
              kind: Backend
              spec: {}
        YAML
      end

      it 'workflow context includes remote crd' do
        expect(product_copy_class).to receive(:workflow) do |context|
          expect(context).to include(source_remote: remote_crd)

          context[:report] = {}
          nil
        end
        subject.run
      end

      it 'workflow context includes product ref' do
        expect(product_copy_class).to receive(:workflow) do |context|
          expect(context).to include(source_service_ref: 'product_a')

          context[:report] = {}
          nil
        end
        subject.run
      end
    end
  end
end
