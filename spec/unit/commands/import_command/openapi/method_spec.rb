RSpec.describe 'OpenAPI Method' do
  class OpenAPIMethodClass
    include ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::Method

    attr_reader :operation

    def initialize(operation)
      @operation = operation
    end
  end

  context '#method' do
    let(:operation_id) { 'Some Operation ID' }
    let(:operation) { { operation_id: operation_id } }
    subject { OpenAPIMethodClass.new(operation).method }

    it 'contains "friendly_name"' do
      is_expected.to include('friendly_name' => operation_id)
    end

    it 'contains "system_name"' do
      is_expected.to include('system_name')
    end

    it '"system_name" is sanitized' do
      is_expected.to include('system_name' => 'some_operation_id')
    end
  end

  context 'operation id not available' do
    let(:operation) { { verb: 'get', path: '/pet/{petId}' } }

    subject { OpenAPIMethodClass.new(operation).method }

    it 'contains "friendly_name"' do
      is_expected.to include('friendly_name' => 'getpetpetId')
    end

    it 'contains "system_name"' do
      is_expected.to include('system_name' => 'getpetpetid')
    end
  end
end
