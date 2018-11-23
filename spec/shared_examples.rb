RSpec.shared_examples 'a copied service' do
  let(:source_settings) { source.show_service }
  let(:target_settings) { target.show_service }
  let(:source_proxy_settings) { source.show_proxy }
  let(:target_proxy_settings) { target.show_proxy }
  let(:source_methods) { source.methods }
  let(:target_methods) { target.methods }
  let(:source_metrics) { source.metrics }
  let(:target_metrics) { target.metrics }
  let(:source_plans) { source.plans }
  let(:target_plans) { target.plans }
  let(:source_mapping_rules) { source.mapping_rules }
  let(:target_mapping_rules) { target.mapping_rules }

  # should be divided into several tests, but testing takes long time to complete
  # and reduce probability of net timeouts
  it 'match' do
    # service settings
    valid_params = ThreeScaleToolbox::Entities::Service::VALID_PARAMS - ['system_name']
    expect(
      # looking forward to Hash.slice on ruby 2.5
      target_settings.select { |k, _| valid_params.include?(k) }
    ).to eq(source_settings.select { |k, _| valid_params.include?(k) })

    # service proxy settings
    valid_params = %w[api_backend auth_app_key auth_app_id auth_user_key credentials_location]
    expect(
      target_proxy_settings.select { |k, _| valid_params.include?(k) }
    ).to eq(source_proxy_settings.select { |k, _| valid_params.include?(k) })

    # methods
    expect(source_methods.size).to be > 0
    source_methods.each do |source_method|
      brother_method = target_methods.find do |target_method|
        ThreeScaleToolbox::Helper.compare_hashes(source_method,
                                                 target_method,
                                                 %w[friendly_name system_name])
      end
      expect(brother_method).not_to be_nil
    end

    # metrics
    expect(source_metrics.size).to be > 0
    metrics_mapping = {}
    source_metrics.each do |source_metric|
      brother_metric = target_metrics.find do |target_metric|
        ThreeScaleToolbox::Helper.compare_hashes(source_metric,
                                                 target_metric,
                                                 %w[name system_name unit])
      end
      expect(brother_metric).not_to be_nil
      metrics_mapping[source_metric['id']] = brother_metric['id']
    end

    # application plans
    # TODO use application_plan_mapping and check created map is correct
    expect(source_plans.size).to be > 0
    source_plans.each do |source_plan|
      brother_plan = target_plans.find do |target_plan|
        ThreeScaleToolbox::Helper.compare_hashes(source_plan,
                                                 target_plan,
                                                 %w[name system_name custom state])
      end
      expect(brother_plan).not_to be_nil

      # limits #TODO repeat loop on source_plans given plan mapping
      source_limits = source.plan_limits(source_plan['id'])
      expect(source_limits.size).to be > 0

      target_limits = target.plan_limits(brother_plan['id'])
      source_limits.each do |source_limit|
        brother_limit = target_limits.find do |target_limit|
          ThreeScaleToolbox::Helper.compare_hashes(source_limit, target_limit, %w[period value]) &&
            metrics_mapping.fetch(source_limit.fetch('metric_id')) == target_limit.fetch('metric_id')
        end
        expect(brother_limit).not_to be_nil
      end
    end

    # mapping rules
    expect(source_mapping_rules.size).to be > 0
    source_mapping_rules.each do |source_mapping_rule|
      brother_mapping_rule = target_mapping_rules.find do |target_mapping_rule|
          ThreeScaleToolbox::Helper.compare_hashes(source_mapping_rule, target_mapping_rule, %w[pattern http_method delta]) &&
            metrics_mapping.fetch(source_mapping_rule.fetch('metric_id')) == target_mapping_rule.fetch('metric_id')
      end
      expect(brother_mapping_rule).not_to be_nil
    end
  end
end
