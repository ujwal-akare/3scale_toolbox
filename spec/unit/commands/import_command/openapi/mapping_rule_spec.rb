RSpec.describe 'OpenAPI Mapping Rule' do
  class OpenAPIMappingRuleClass
    include ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::MappingRule

    attr_reader :operation

    def initialize(operation)
      @operation = operation
    end
  end

  context '#mapping_rule' do
    let(:verb) { 'POST' }
    let(:path) { '/some/path' }
    let(:metric_id) { '1' }
    let(:operation) { { verb: verb, path: path, metric_id: metric_id } }
    subject { OpenAPIMappingRuleClass.new(operation).mapping_rule }

    it 'contains "pattern"' do
      is_expected.to include('pattern' => path)
    end

    it 'contains "http_method"' do
      is_expected.to include('http_method' => verb.upcase)
    end

    it 'contains "delta"' do
      is_expected.to include('delta' => 1)
    end

    it 'contains "metric_id"' do
      is_expected.to include('metric_id' => metric_id)
    end
  end
end
