RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateMethodsStep do
  subject { described_class.new(openapi_context) }
  let(:service) { double('service') }
  let(:op0) { double('op0') }
  let(:op1) { double('op1') }
  let(:operations) { [op0, op1] }
  let(:openapi_context) { { operations: operations, target: service } }
  let(:method_0) { { 'id' => '0', 'system_name' => 'method0' } }
  let(:method_1) { { 'id' => '1', 'system_name' => 'method1' } }
  let(:hits_metric) { { 'id' => '1' } }

  context '#call' do
    before :example do
      expect(service).to receive(:hits).and_return(hits_metric)

    end

    context 'when methods do not exist' do
      before :example do
        expect(service).to receive(:create_method).with('1', method_0).and_return('id' => '0')
        expect(service).to receive(:create_method).with('1', method_1).and_return('id' => '1')
        expect(op0).to receive(:method).and_return(method_0)
        expect(op1).to receive(:method).and_return(method_1)
      end

      it 'methods created' do
        expect(op0).to receive(:set).with(:metric_id, '0')
        expect(op1).to receive(:set).with(:metric_id, '1')
        subject.call
      end
    end

    context 'when methods exist' do
      let(:create_method_error) do
        {
          'errors' => {
            'system_name' => ['has already been taken'],
            'friendly_name' => ['has already been taken']
          }
        }
      end

      before :example do
        expect(service).to receive(:methods).and_return([method_0, method_1])
        expect(service).to receive(:create_method).with('1', method_0)
                                                  .and_return(create_method_error)
        expect(service).to receive(:create_method).with('1', method_1)
                                                  .and_return(create_method_error)
        expect(op0).to receive(:method).twice.and_return(method_0)
        expect(op1).to receive(:method).twice.and_return(method_1)
      end

      it 'methods not created' do
        expect(op0).to receive(:set).with(:metric_id, '0')
        expect(op1).to receive(:set).with(:metric_id, '1')
        subject.call
      end
    end

    context 'when create method returns unexpected' do
      let(:create_method_error) do
        {
          'errors' => {
            'friendly_name' => ['something went wrong']
          }
        }
      end
      before :example do
        expect(op0).to receive(:method).and_return(method_0)
        expect(service).to receive(:create_method).and_return(create_method_error)
      end

      it 'error raised' do
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error)
      end
    end
  end
end
