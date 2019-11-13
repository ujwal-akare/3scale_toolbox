RSpec.describe 'Method delete command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) { "method delete #{client_url} #{service_ref} #{method_ref}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:method_ref) { "method_#{random_lowercase_name}" }
  let(:service_hits_id) { service.hits.fetch('id') }

  before :example do
    # add method
    method_attrs = { 'system_name' => method_ref, 'friendly_name' => method_ref }
    ThreeScaleToolbox::Entities::Method.create(service: service,
                                               parent_id: service_hits_id,
                                               attrs: method_attrs)
  end

  after :example do
    service.delete
  end

  it 'method is deleted' do
    expect(subject).to eq(0)

    expect(ThreeScaleToolbox::Entities::Method.find(service: service, parent_id: service_hits_id,
                                                    ref: method_ref)).to be_nil
  end
end
