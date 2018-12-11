RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMethodsStep do
  subject { described_class.new(openapi_context) }
  let(:service) { double('service') }
  let(:op0) { double('op0') }
  let(:op1) { double('op1') }
  let(:operations) { [op0, op1] }
  let(:openapi_context) { { operations: operations, service: service } }
  let(:method_0) { double('method_0') }
  let(:method_1) { double('method_1') }
  let(:hits_metric) { { 'id' => 1 } }

  context '#call' do
    before :each do
      allow(service).to receive(:hits).and_return(hits_metric)

      allow(op0).to receive(:method).and_return(method_0)
      allow(op0).to receive(:set)

      allow(op1).to receive(:method).and_return(method_1)
      allow(op1).to receive(:set)

      allow(service).to receive(:create_method).and_return({})
    end

    it 'method from "op0" created' do
      expect(service).to receive(:create_method).with(1, method_0).and_return('id' => 0)
      expect(op0).to receive(:set).with(:metric_id, 0)
      subject.call
    end

    it 'method from "op1" created' do
      expect(service).to receive(:create_method).with(1, method_1).and_return('id' => 1)
      expect(op1).to receive(:set).with(:metric_id, 1)
      subject.call
    end
  end
end
