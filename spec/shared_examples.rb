RSpec.shared_examples 'service settings' do
  compare_keys = ThreeScaleToolbox::Entities::Service::VALID_PARAMS - ['system_name']

  it 'ok' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(
      # looking forward to Hash.slice on ruby 2.5
      target_service.show_service.select { |k, _| compare_keys.include?(k) }
    ).to eq(source_service.show_service.select { |k, _| compare_keys.include?(k) })
  end
end

RSpec.shared_examples 'proxy settings' do
  compare_keys = %w[api_backend auth_app_key auth_app_id auth_user_key credentials_location]

  it 'ok' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(
      # looking forward to Hash.slice on ruby 2.5
      target_service.show_proxy.select { |k, _| compare_keys.include?(k) }
    ).to eq(source_service.show_proxy.select { |k, _| compare_keys.include?(k) })
  end
end

RSpec.shared_examples 'service methods' do
  let(:source_methods) { source_service.methods }
  let(:target_methods) { target_service.methods }
  let(:method_keys) { %w[friendly_name system_name] }

  it 'match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(source_methods.size).to be > 0
    expect(source_methods).to be_subset_of(target_methods).comparing_keys(method_keys)
  end
end

RSpec.shared_examples 'service metrics' do
  include_context :toolbox_tasks_helper
  include_context :copied_metrics

  it 'match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(source_metrics.size).to be > 0
    expect(source_metrics).to be_subset_of(target_metrics).comparing_keys(metric_keys)
  end
end

RSpec.shared_examples 'service plans' do
  include_context :toolbox_tasks_helper
  include_context :copied_plans

  it 'match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(source_plans.size).to be > 0
    source_plans.each do |source_plan|
      copied_plan = plan_mapping.fetch(source_plan['id'])
      expect(
        copied_plan.select { |k, _| plan_keys.include?(k) }
      ).to eq(source_plan.select { |k, _| plan_keys.include?(k) })
    end
  end
end

RSpec.shared_examples 'service plan limits' do
  include_context :toolbox_tasks_helper
  include_context :copied_plans
  include_context :copied_metrics

  def limit_match(limit_a, limit_b, metrics_mapping)
    ThreeScaleToolbox::Helper.compare_hashes(limit_a, limit_b, %w[period value]) &&
      metrics_mapping.fetch(limit_a.fetch('metric_id')) == limit_b.fetch('metric_id')
  end

  def limit_mapping(limits_a, limits_b, metrics_mapping)
    limits_a.map do |limit_a|
      found_limit = limits_b.find do |limit_b|
        limit_match(limit_a, limit_b, metrics_mapping)
      end
      [limit_a, found_limit]
    end.to_h
  end

  it 'plans limits match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    # already checked there exist more than one app plan
    source_plans.each do |source_plan_attrs|
      source_plan = ThreeScaleToolbox::Entities::ApplicationPlan.new(id: source_plan_attrs['id'],
                                                                     service: source_service)
      # For each plan, get {source, target} limits
      # Expect for each limit in source,
      # there exists a target limit with custom eq method
      source_limits = source_plan.limits
      expect(source_limits.size).to be > 0
      copied_plan = plan_mapping.fetch(source_plan.id)
      target_plan = ThreeScaleToolbox::Entities::ApplicationPlan.new(id: copied_plan['id'],
                                                                     service: target_service)
      limit_map = limit_mapping(source_limits, target_plan.limits, metrics_mapping)
      # Check all mapped values are not nil
      expect(limit_map.size).to be > 0
      expect(limit_map.values).not_to include(nil)
    end
  end
end

RSpec.shared_examples 'service mapping rules' do
  include_context :toolbox_tasks_helper
  include_context :copied_metrics

  let(:source_mapping_rules) { source_service.mapping_rules }
  let(:target_mapping_rules) { target_service.mapping_rules }
  let(:mapping_rule_keys) { %w[pattern http_method delta] }

  def mapping_rule_match(src, target, metrics_mapping, keys)
    ThreeScaleToolbox::Helper.compare_hashes(src, target, keys) &&
      metrics_mapping.fetch(src.fetch('metric_id')) == target.fetch('metric_id')
  end

  it 'mapping rules match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(source_mapping_rules.size).to be > 0
    source_mapping_rules.each do |source_mapping_rule|
      copied_mapping_rule = target_mapping_rules.find do |target_mapping_rule|
        mapping_rule_match(source_mapping_rule, target_mapping_rule, metrics_mapping, mapping_rule_keys)
      end
      expect(
        copied_mapping_rule.select { |k, _| mapping_rule_keys.include?(k) }
      ).to eq(source_mapping_rule.select { |k, _| mapping_rule_keys.include?(k) })
    end
  end
end

RSpec.shared_examples 'service proxy policies' do
  let(:source_policies) { source_service.policies }
  let(:target_policies) { target_service.policies }

  it 'match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(source_policies.size).to be > 3
    expect(target_policies).to match_array(source_policies)
  end
end

RSpec.shared_examples 'service pricing rules' do
  include_context :toolbox_tasks_helper
  include_context :copied_plans
  include_context :copied_metrics

  def limit_match(limit_a, limit_b, metrics_mapping)
    ThreeScaleToolbox::Helper.compare_hashes(limit_a, limit_b, %w[period value]) &&
      metrics_mapping.fetch(limit_a.fetch('metric_id')) == limit_b.fetch('metric_id')
  end

  def pricingrule_mapping(limits_a, limits_b, metrics_mapping)
    limits_a.map do |limit_a|
      found_limit = limits_b.find do |limit_b|
        limit_match(limit_a, limit_b, metrics_mapping)
      end
      [limit_a, found_limit]
    end.to_h
  end

  it 'pricing rules match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    # already checked there exist more than one app plan
    source_plans.each do |source_plan|
      # For each plan, get {source, target} pricing rules
      # Expect for each pricing rules in source plan,
      # there should exists the same target pricing rule
      source_pricingrules = source_service.remote.list_pricingrules_per_application_plan(source_plan['id'])
      expect(source_pricingrules.size).to be > 0
      copied_plan = plan_mapping.fetch(source_plan['id'])
      target_pricingrules = target_service.remote.list_pricingrules_per_application_plan(copied_plan['id'])
      # the difference should be empty set
      missing_pricingrules = ThreeScaleToolbox::Helper.array_difference(source_pricingrules, target_pricingrules) do |src, target|
        ThreeScaleToolbox::Helper.compare_hashes(src, target, ['system_name'])
      end
      expect(missing_pricingrules.size).to be_zero
    end
  end
end

RSpec.shared_examples 'service activedocs' do
  let(:source_activedocs) { source_service.list_activedocs }
  let(:target_activedocs) { target_service.list_activedocs }
  let(:activedocs_keys) { %w[name] }

  it 'match' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(source_activedocs.size).to be > 0
    expect(source_activedocs).to be_subset_of(target_activedocs).comparing_keys(activedocs_keys)
  end
end
