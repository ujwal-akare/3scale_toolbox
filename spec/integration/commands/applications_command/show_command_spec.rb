RSpec.describe 'Application show command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:application_id) { random_lowercase_name }
  let(:application_name) { "app_#{random_lowercase_name}" }
  let(:command_line_str) { "application show #{client_url} #{application_id}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:service_attrs) do
    {
      'name' => 'API 1', 'system_name' => service_ref, 'backend_version' => '2'
    }
  end
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }
  let(:plan_attrs) { { 'name' => 'some_name', 'system_name' => plan_ref } }
  let(:plan) do
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end
  let(:account_name) { "account_#{random_lowercase_name}" }
  let(:account) { api3scale_client.signup(name: account_name, username: account_name) }

  before :example do
    # create application
    app_attrs = {
      'name' => application_name,
      'description' => "app #{random_lowercase_name}",
      'application_id' => application_id,
      'application_key' => random_lowercase_name
    }
    ThreeScaleToolbox::Entities::Application.create(remote: api3scale_client,
                                                    account_id: account['id'],
                                                    plan_id: plan.id,
                                                    app_attrs: app_attrs)
  end

  after :example do
    service.delete
    api3scale_client.delete_account(account['id'])
  end

  it 'show app id' do
    expect { subject }.to output(/.*#{application_id}.*/).to_stdout
    expect(subject).to eq(0)
  end
end
