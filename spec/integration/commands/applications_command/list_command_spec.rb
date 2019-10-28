RSpec.describe 'Application list command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:command_line_str) { "application list #{client_url}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
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
  let(:application_name_1) { "app_#{random_lowercase_name}" }
  let(:application_name_2) { "app_#{random_lowercase_name}" }

  before :example do
    # add application
    app_attrs = {
      'name' => application_name_1,
      'description' => "app #{random_lowercase_name}",
      'application_id' => random_lowercase_name,
      'application_key' => random_lowercase_name
    }
    ThreeScaleToolbox::Entities::Application.create(remote: api3scale_client,
                                                    account_id: account['id'],
                                                    plan_id: plan.id,
                                                    app_attrs: app_attrs)
    # add application
    app_attrs = {
      'name' => application_name_2,
      'description' => "app #{random_lowercase_name}",
      'application_id' => random_lowercase_name,
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

  it 'lists app id1' do
    expect { subject }.to output(/.*#{application_name_1}.*/).to_stdout
    expect(subject).to eq(0)
  end

  it 'lists app id2' do
    expect { subject }.to output(/.*#{application_name_2}.*/).to_stdout
    expect(subject).to eq(0)
  end
end
