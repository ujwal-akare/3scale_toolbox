RSpec.describe 'Application Plan show command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) do
    "application-plan show #{client_url} #{service_ref} #{plan_ref}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end

  before :example do
    # Create application plan
    plan_attrs = { 'name' => 'name1', 'system_name' => plan_ref }
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end

  after :example do
    service.delete
  end

  it 'lists plan_ref1' do
    expect { subject }.to output(/.*#{plan_ref}.*/).to_stdout
    expect(subject).to eq(0)
  end
end
