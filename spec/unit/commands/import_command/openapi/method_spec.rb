RSpec.describe 'OpenAPI Method' do
  class OpenAPIMethodClass
    include ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::Method

    attr_reader :operation

    def initialize(operation)
      @operation = operation
    end
  end

  context '#method' do
    let(:operationId) { 'Some Operation ID' }
    let(:operation) { { operationId: operationId } }
    subject { OpenAPIMethodClass.new(operation).method }

    it 'contains "friendly_name"' do
      is_expected.to include('friendly_name' => operationId)
    end

    it 'contains "system_name"' do
      is_expected.to include('system_name' => operationId.downcase)
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
