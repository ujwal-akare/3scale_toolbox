RSpec.describe ThreeScaleToolbox::CRD::BackendParser do
  let(:system_name) { 'some_system_name' }
  let(:name) { 'some name' }
  let(:description) { 'some descr' }
  let(:private_endpoint) { 'https://example.com' }
  let(:metrics) do
    {
      'hits' => {
        'friendlyName' => 'Hits',
        'unit' => 'hit',
        'description' => 'Number of API hits',
      },
      'mybackendmetric01' => {
        'friendlyName' => 'my backendmetric01',
        'unit' => '1',
        'description' => 'mybackendmetric01 desc',
      },
    }
  end
  let(:methods) do
    {
      'mybackendmethod01' => {
        'friendlyName' => 'my backendmethod01',
        'description' => 'mybackendmethod01 desc',
      },
    }
  end

  let(:mapping_rules) do
    [
      {
        'httpMethod' => 'GET',
        'pattern' => '/v1/pets',
        'increment' => 1,
        'last' => true,
        'metricMethodRef' => 'mybackendmethod01',
      }
    ]
  end

  let(:cr) do
    {
      'apiVersion' => 'capabilities.3scale.net/v1beta1',
      'kind' => 'Backend',
      'metadata' => {},
      'spec' => {
        'systemName' => system_name,
        'name' => name,
        'description' => description,
        'privateBaseURL' => private_endpoint,
        'methods' => methods,
        'metrics' => metrics,
        'mappingRules' => mapping_rules,
      }
    }
  end

  subject { described_class.new cr }

  it 'system_name read' do
    expect(subject.system_name).to eq system_name
  end

  it 'name read' do
    expect(subject.name).to eq name
  end

  it 'description read' do
    expect(subject.description).to eq description
  end

  it 'private_endpoint read' do
    expect(subject.private_endpoint).to eq private_endpoint
  end

  it 'hits metric read' do
    hits_metric = subject.metrics.find { |m| m.system_name == 'hits' }
    expect(hits_metric).not_to be_nil
    expect(hits_metric.friendly_name).to eq 'Hits'
    expect(hits_metric.unit).to eq 'hit'
    expect(hits_metric.description).to eq 'Number of API hits'
  end

  it 'mybackendmetric01 metric read' do
    metric = subject.metrics.find { |m| m.system_name == 'mybackendmetric01' }
    expect(metric).not_to be_nil
    expect(metric.friendly_name).to eq 'my backendmetric01'
    expect(metric.unit).to eq '1'
    expect(metric.description).to eq 'mybackendmetric01 desc'
  end

  it 'mybackendmethod01 method read' do
    method = subject.methods.find { |m| m.system_name == 'mybackendmethod01' }
    expect(method).not_to be_nil
    expect(method.friendly_name).to eq 'my backendmethod01'
    expect(method.description).to eq 'mybackendmethod01 desc'
  end

  it 'mapping rule read' do
    expect(subject.mapping_rules).not_to be_nil
    expect(subject.mapping_rules.length).to eq 1
    expect(subject.mapping_rules[0].metric_ref).to eq 'mybackendmethod01'
    expect(subject.mapping_rules[0].http_method).to eq 'GET'
    expect(subject.mapping_rules[0].pattern).to eq '/v1/pets'
    expect(subject.mapping_rules[0].delta).to eq 1
    expect(subject.mapping_rules[0].last).to be_truthy
  end

  it 'metric index correct' do
    expect(subject.metrics_index.keys).to contain_exactly('hits', 'mybackendmetric01', 'mybackendmethod01')
    expect(subject.metrics_index.fetch('hits').friendly_name).to eq 'Hits'
    expect(subject.metrics_index.fetch('mybackendmetric01').friendly_name).to eq 'my backendmetric01'
    expect(subject.metrics_index.fetch('mybackendmethod01').friendly_name).to eq 'my backendmethod01'
  end
end
