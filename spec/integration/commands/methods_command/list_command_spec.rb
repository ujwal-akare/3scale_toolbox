RSpec.describe 'Method list command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) { "method list #{client_url} #{service_ref}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:method_ref1) { "method_#{random_lowercase_name}" }
  let(:method_ref2) { "method_#{random_lowercase_name}" }

  before :example do
    # add method
    method_attrs = { 'system_name' => method_ref1, 'friendly_name' => method_ref1 }
    ThreeScaleToolbox::Entities::Method.create(service: service, attrs: method_attrs)
    # add method
    method_attrs = { 'system_name' => method_ref2, 'friendly_name' => method_ref2 }
    ThreeScaleToolbox::Entities::Method.create(service: service, attrs: method_attrs)
  end

  after :example do
    service.delete
  end

  it 'lists method_ref1' do
    expect { subject }.to output(/.*#{method_ref1}.*/).to_stdout
    expect(subject).to eq(0)
  end

  it 'lists method_ref2' do
    expect { subject }.to output(/.*#{method_ref2}.*/).to_stdout
    expect(subject).to eq(0)
  end
end
