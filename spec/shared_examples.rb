RSpec.shared_examples 'service copied' do
  include_context :copied_metrics
  include_context :copied_plans

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

  def mapping_rule_match(src, target, metrics_mapping, keys)
    ThreeScaleToolbox::Helper.compare_hashes(src, target, keys) &&
      metrics_mapping.fetch(src.fetch('metric_id')) == target.fetch('metric_id')
  end

  def pricingrule_mapping(limits_a, limits_b, metrics_mapping)
    limits_a.map do |limit_a|
      found_limit = limits_b.find do |limit_b|
        limit_match(limit_a, limit_b, metrics_mapping)
      end
      [limit_a, found_limit]
    end.to_h
  end

  it do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)

    # target_service has stale data after updating service
    target_service_new = ThreeScaleToolbox::Entities::Service.new(id: target_service.id,
                                                                  remote: target_service.remote)

    # service settings
    compare_keys = ThreeScaleToolbox::Entities::Service::VALID_PARAMS - ['system_name']

    source_settings = source_service.attrs.slice(compare_keys)
    target_settings = target_service_new.attrs.slice(compare_keys)
    expect(target_settings).to eq(source_settings)

    # proxy settings
    compare_keys = %w[api_backend auth_app_key auth_app_id auth_user_key credentials_location]
    expect(target_service_new.proxy.slice(compare_keys)).to eq(source_service.proxy.slice(compare_keys))

    # service methods
    source_hits_id = source_service.hits['id']
    target_hits_id = target_service_new.hits['id']
    source_methods = source_service.methods source_hits_id
    target_methods = target_service_new.methods target_hits_id
    method_keys = %w[friendly_name system_name]
    expect(source_methods.size).to be > 0
    expect(source_methods).to be_subset_of(target_methods).comparing_keys(method_keys)

    # service metrics
    expect(source_metrics.size).to be > 0
    expect(source_metrics).to be_subset_of(target_metrics).comparing_keys(metric_keys)

    # service plans
    expect(source_plans.size).to be > 0
    source_plans.each do |source_plan|
      copied_plan = plan_mapping.fetch(source_plan['id'])
      expect(
        copied_plan.select { |k, _| plan_keys.include?(k) }
      ).to eq(source_plan.select { |k, _| plan_keys.include?(k) })
    end

    # service plan limits
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
                                                                     service: target_service_new)
      limit_map = limit_mapping(source_limits, target_plan.limits, metrics_mapping)
      # Check all mapped values are not nil
      expect(limit_map.size).to be > 0
      expect(limit_map.values).not_to include(nil)
    end

    # service mapping rules
    source_mapping_rules = source_service.mapping_rules
    target_mapping_rules = target_service_new.mapping_rules
    mapping_rule_keys = %w[pattern http_method delta]
    expect(source_mapping_rules.size).to be > 0
    source_mapping_rules.each do |source_mapping_rule|
      copied_mapping_rule = target_mapping_rules.find do |target_mapping_rule|
        mapping_rule_match(source_mapping_rule, target_mapping_rule, metrics_mapping, mapping_rule_keys)
      end
      expect(
        copied_mapping_rule.select { |k, _| mapping_rule_keys.include?(k) }
      ).to eq(source_mapping_rule.select { |k, _| mapping_rule_keys.include?(k) })
    end
    # service proxy policies
    source_policies = source_service.policies
    target_policies = target_service_new.policies
    expect(source_policies.size).to be > 3
    expect(target_policies).to match_array(source_policies)

    # service pricing rules
    # already checked there exist more than one app plan
    source_plans.each do |source_plan|
      # For each plan, get {source, target} pricing rules
      # Expect for each pricing rules in source plan,
      # there should exists the same target pricing rule
      source_pricingrules = source_service.remote.list_pricingrules_per_application_plan(source_plan['id'])
      expect(source_pricingrules.size).to be > 0
      copied_plan = plan_mapping.fetch(source_plan['id'])
      target_pricingrules = target_service_new.remote.list_pricingrules_per_application_plan(copied_plan['id'])
      # the difference should be empty set
      missing_pricingrules = ThreeScaleToolbox::Helper.array_difference(source_pricingrules, target_pricingrules) do |src, target|
        ThreeScaleToolbox::Helper.compare_hashes(src, target, ['system_name'])
      end
      expect(missing_pricingrules.size).to be_zero
    end

    # service activedocs
    source_activedocs = source_service.activedocs
    target_activedocs = target_service_new.activedocs
    activedocs_keys = %w[name]
    expect(source_activedocs.size).to be > 0
    expect(source_activedocs).to be_subset_of(target_activedocs).comparing_keys(activedocs_keys)
  end
end
