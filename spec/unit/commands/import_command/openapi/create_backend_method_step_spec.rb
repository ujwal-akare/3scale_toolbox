RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateBackendMethodsStep do
  subject { described_class.new(openapi_context) }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend) }
  let(:method_class) { class_double(ThreeScaleToolbox::Entities::BackendMethod).as_stubbed_const }
  let(:method_0) { instance_double(ThreeScaleToolbox::Entities::BackendMethod) }
  let(:method_1) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:op0) { double('op0') }
  let(:op1) { double('op1') }
  let(:operations) { [op0, op1] }
  let(:openapi_context) { { operations: operations, backend_target: backend } }
  let(:method_0_attrs) { { 'id' => 0, 'system_name' => 'method0' } }
  let(:method_1_attrs) { { 'id' => 1, 'system_name' => 'method1' } }

  context '#call' do
    before :example do
      allow(op0).to receive(:method).and_return(method_0_attrs)
      allow(op1).to receive(:method).and_return(method_1_attrs)
    end

    context 'when methods do not exist' do
      before :example do
        expect(method_class).to receive(:create).with(backend: backend, attrs: method_0_attrs)
                                                .and_return(method_0)
        expect(method_class).to receive(:create).with(backend: backend, attrs: method_1_attrs)
                                                .and_return(method_1)
        expect(method_0).to receive(:id).and_return(0)
        expect(method_1).to receive(:id).and_return(1)
        expect(backend).to receive(:methods).and_return([])
      end

      it 'methods created' do
        expect(op0).to receive(:set).with(:metric_id, 0)
        expect(op1).to receive(:set).with(:metric_id, 1)
        subject.call
      end
    end

    context 'when methods exist' do
      before :example do
        expect(backend).to receive(:methods).and_return([method_0, method_1])
        allow(method_0).to receive(:system_name).and_return(method_0_attrs['system_name'])
        allow(method_1).to receive(:system_name).and_return(method_1_attrs['system_name'])
        allow(method_0).to receive(:attrs).and_return(method_0_attrs)
        allow(method_1).to receive(:attrs).and_return(method_1_attrs)
        expect(method_class).to receive(:new).with(id: 0, backend: backend)
                                             .and_return(method_0)
        expect(method_class).to receive(:new).with(id: 1, backend: backend)
                                             .and_return(method_1)
        expect(method_0).to receive(:update).with(method_0_attrs)
        expect(method_1).to receive(:update).with(method_1_attrs)
        expect(method_0).to receive(:id).and_return(0)
        expect(method_1).to receive(:id).and_return(1)
      end

      it 'methods not created' do
        expect(op0).to receive(:set).with(:metric_id, 0)
        expect(op1).to receive(:set).with(:metric_id, 1)
        subject.call
      end
    end
  end
end
