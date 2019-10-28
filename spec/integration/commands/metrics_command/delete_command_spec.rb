RSpec.describe 'Metric delete command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) { "metric delete #{client_url} #{service_ref} #{metric_ref}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:metric_ref) { "metric_#{random_lowercase_name}" }

  before :example do
    # add metric
    metric_attrs = { 'system_name' => metric_ref, 'unit': '1', 'friendly_name' => metric_ref }
    ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: metric_attrs)
  end

  after :example do
    service.delete
  end

  it 'metric is deleted' do
    expect(subject).to eq(0)

    expect(ThreeScaleToolbox::Entities::Metric.find(service: service, ref: metric_ref)).to be_nil
  end
end
