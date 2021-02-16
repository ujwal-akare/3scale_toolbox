RSpec.describe 'Application Plan Import' do
  include_context :real_api3scale_client
  include_context :resources
  include_context :random_name

  let(:file) { File.join(resources_path, 'plan.yaml') }
  let(:remote) { client_url }
  let(:service_system_name) { "service_#{random_lowercase_name}" }
  let(:service_obj) { { 'name' => service_system_name, 'system_name' => service_system_name } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_obj
    )
  end

  # plan system name does not conflict with app plans belonging to other services
  let(:command_line_str) do
    "application-plan import -f #{file} #{remote} #{service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  after :example do
    service.delete
  end

  it do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    file_plan_obj = YAML.safe_load(File.read(file))
    file_plan = file_plan_obj['plan']
    file_limits = file_plan_obj['limits']
    file_limit = file_limits[0]
    file_pricingrules = file_plan_obj['pricingrules']
    file_pricingrule = file_pricingrules[0]
    file_features = file_plan_obj['plan_features']
    file_feature = file_features[0]
    file_metrics = file_plan_obj['metrics']
    file_metric = file_metrics[0]
    file_methods = file_plan_obj['methods']
    file_method = file_methods[0]
    service_metrics = service.metrics
    expect(service_metrics).not_to be_empty
    service_methods = service.methods
    expect(service_methods).not_to be_empty
    service_all_metrics = service_metrics + service_methods

    remote_plan_client = ThreeScaleToolbox::Entities::ApplicationPlan.find(
      service: service, ref: file_plan['system_name']
    )
    expect(remote_plan_client).not_to be_nil

    # check imported plan attrs match plan attr read from remote
    expect(remote_plan_client.attrs).to include(file_plan)

    # check imported plan limts
    remote_plan_limits = remote_plan_client.limits
    expect(remote_plan_limits.size).to eq(1)
    remote_plan_limit = remote_plan_limits[0]
    ## compare limit read from remote and limit read from file
    expect(remote_plan_limit.attrs).to include(file_limit.clone.tap { |h| h.delete('metric_system_name') })
    ## check metric_id refer to a metric with metric_system_name from file limit
    limit_metric = service_all_metrics.find do |m|
      m.id == remote_plan_limit.metric_id
    end
    expect(limit_metric).not_to be_nil
    expect(limit_metric.system_name).to eq(file_limit.fetch('metric_system_name'))

    # check import plan pricing rules
    remote_plan_prs = remote_plan_client.pricing_rules
    expect(remote_plan_prs.size).to eq(1)
    remote_plan_pr = remote_plan_prs[0]
    ## compare pricing rule read from remote and pricing rule read from file
    expect(remote_plan_pr.attrs).to include(file_pricingrule.clone.tap { |h| h.delete('metric_system_name') })
    ## check metric_id refer to a metric with metric_system_name from file pricing rule
    pr_metric = service_all_metrics.find do |m|
      m.id == remote_plan_pr.metric_id
    end
    expect(pr_metric).not_to be_nil
    expect(pr_metric.system_name).to eq(file_pricingrule.fetch('metric_system_name'))

    # check imported plan features
    remote_plan_features = remote_plan_client.features
    expect(remote_plan_features.size).to eq(1)
    remote_plan_feature = remote_plan_features[0]
    expect(remote_plan_feature).to include(file_feature)

    # check imported methods are subset of service methods
    expect(file_methods).to be_subset_of(service_methods.map(&:attrs)).comparing_keys(file_method.keys)

    ## check imported metrics are subset of service metrics
    expect(file_metrics).to be_subset_of(service_all_metrics.map(&:attrs)).comparing_keys(file_metric.keys)
  end
end
