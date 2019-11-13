RSpec.describe 'Metric list command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) { "metric list #{client_url} #{service_ref}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:metric_ref1) { "metric_#{random_lowercase_name}" }
  let(:metric_ref2) { "metric_#{random_lowercase_name}" }

  before :example do
    # add metric
    metric_attrs = { 'system_name' => metric_ref1, 'unit' => 1, 'friendly_name' => metric_ref1 }
    ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: metric_attrs)
    # add metric
    metric_attrs = { 'system_name' => metric_ref2, 'unit' => 1, 'friendly_name' => metric_ref2 }
    ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: metric_attrs)
  end

  after :example do
    service.delete
  end

  it 'lists metric_ref1' do
    expect { subject }.to output(/.*#{metric_ref1}.*/).to_stdout
    expect(subject).to eq(0)
  end

  it 'lists metric_ref2' do
    expect { subject }.to output(/.*#{metric_ref2}.*/).to_stdout
    expect(subject).to eq(0)
  end
end
