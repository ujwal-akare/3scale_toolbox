RSpec.shared_examples 'comparable objects' do
  it 'match keys' do
    expect(
      # looking forward to Hash.slice on ruby 2.5
      second.select { |k, _| keys.include?(k) }
    ).to eq(first.select { |k, _| keys.include?(k) })
  end
end

RSpec.shared_examples 'service settings copied' do
  let(:source_settings) { source.show_service }
  let(:target_settings) { target.show_service }
  let(:keys) { ThreeScaleToolbox::Entities::Service::VALID_PARAMS - ['system_name'] }
  let(:first) { source_settings }
  let(:second) { target_settings }

  it_behaves_like 'comparable objects'
end

RSpec.shared_examples 'proxy copied' do
  let(:source_proxy) { source.show_proxy }
  let(:target_proxy) { target.show_proxy }
  let(:keys) { %w[api_backend auth_app_key auth_app_id auth_user_key credentials_location] }
  let(:first) { source_proxy }
  let(:second) { target_proxy }

  it_behaves_like 'comparable objects'
end

RSpec.shared_examples 'service methods copied' do
  let(:source_methods) { source.methods }
  let(:target_methods) { target.methods }
  let(:method_keys) { %w[friendly_name system_name] }

  it 'methods exist' do
    expect(source_methods.size).to be > 0
  end

  it 'methods match' do
    source_methods.each do |source_method|
      copied_method = target_methods.find do |target_method|
        ThreeScaleToolbox::Helper.compare_hashes(source_method, target_method, method_keys)
      end
      expect(
        copied_method.select { |k, _| method_keys.include?(k) }
      ).to eq(source_method.select { |k, _| method_keys.include?(k) })
    end
  end
end

RSpec.shared_examples 'service metrics copied' do
  include_context :toolbox_tasks_helper
  include_context :copied_metrics

  it 'metrics exist' do
    expect(source_metrics.size).to be > 0
  end

  it 'metrics match' do
    source_metrics.each do |source_metric|
      copied_metric = target_metrics.find do |target_metric|
        ThreeScaleToolbox::Helper.compare_hashes(source_metric, target_metric, metric_keys)
      end
      expect(
        copied_metric.select { |k, _| metric_keys.include?(k) }
      ).to eq(source_metric.select { |k, _| metric_keys.include?(k) })
    end
  end
end

RSpec.shared_examples 'service plans copied' do
  include_context :toolbox_tasks_helper
  include_context :copied_plans

  it 'plans exist' do
    expect(source_plans.size).to be > 0
  end

  it 'plans match' do
    source_plans.each do |source_plan|
      copied_plan = plan_mapping.fetch(source_plan['id'])
      expect(
        copied_plan.select { |k, _| plan_keys.include?(k) }
      ).to eq(source_plan.select { |k, _| plan_keys.include?(k) })
    end
  end
end

RSpec.shared_examples 'service plan limits copied' do
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
    # already checked there exist more than one app plan
    source_plans.each do |source_plan|
      # For each plan, get {source, target} limits
      # Expect for each limit in source,
      # there exists a target limit with custom eq method
      source_limits = source.plan_limits(source_plan['id'])
      expect(source_limits.size).to be > 0
      copied_plan = plan_mapping.fetch(source_plan['id'])
      target_limits = target.plan_limits(copied_plan['id'])
      limit_map = limit_mapping(source_limits, target_limits, metrics_mapping)
      # Check all mapped values are not nil
      expect(limit_map.size).to be > 0
      expect(limit_map.values).not_to include(nil)
    end
  end
end

RSpec.shared_examples 'service mapping rules copied' do
  include_context :toolbox_tasks_helper
  include_context :copied_metrics

  let(:source_mapping_rules) { source.mapping_rules }
  let(:target_mapping_rules) { target.mapping_rules }
  let(:mapping_rule_keys) { %w[pattern http_method delta] }

  it 'mapping rules exist' do
    expect(source_mapping_rules.size).to be > 0
  end

  def mapping_rule_match(src, target, metrics_mapping, keys)
    ThreeScaleToolbox::Helper.compare_hashes(src, target, keys) &&
      metrics_mapping.fetch(src.fetch('metric_id')) == target.fetch('metric_id')
  end

  it 'mapping rules match' do
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
