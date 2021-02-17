RSpec.describe ThreeScaleToolbox::CRD::Remote do
  let(:system_name) { 'some_system_name' }
  let(:name) { 'some name' }
  let(:description) { 'some descr' }

  let(:backend_01_metrics) do
    {
      'hits' => {
        'friendlyName' => 'Hits',
        'unit' => 'hit',
        'description' => 'Number of API hits',
      }
    }
  end

  let(:backend_02_metrics) { backend_01_metrics }

  let(:backend_01_methods) do
    {
      'backend_01_method' => {
        'friendlyName' => 'my backend_01_method',
        'description' => 'backend_01_method desc',
      },
    }
  end

  let(:backend_02_methods) do
    {
      'backend_02_method' => {
        'friendlyName' => 'my backend_02_method',
        'description' => 'backend_02_method desc',
      },
    }
  end

  let(:backend_01_mapping_rules) do
    [
      {
        'httpMethod' => 'GET',
        'pattern' => '/v1/pets',
        'increment' => 1,
        'last' => true,
        'metricMethodRef' => 'backend_01_method',
      }
    ]
  end

  let(:backend_02_mapping_rules) do
    [
      {
        'httpMethod' => 'GET',
        'pattern' => '/v1/pets',
        'increment' => 1,
        'last' => true,
        'metricMethodRef' => 'backend_02_method',
      }
    ]
  end

  let(:metrics) do
    {
      'hits' => {
        'friendlyName' => 'Hits',
        'unit' => 'hit',
        'description' => 'Number of API hits',
      },
      'mymetric01' => {
        'friendlyName' => 'my metric01',
        'unit' => '1',
        'description' => 'mymetric01 desc',
      },
    }
  end

  let(:methods) do
    {
      'mymethod01' => {
        'friendlyName' => 'my method01',
        'description' => 'mymethod01 desc',
      },
    }
  end

  let(:mapping_rules) do
    [
      {
        'httpMethod' => 'GET',
        'pattern' => '/v1/pets',
        'increment' => 1,
        'last' => true,
        'metricMethodRef' => 'mymethod01',
      }
    ]
  end

  let(:gateway_response) do
    {
      'errorStatusAuthFailed' => '1',
      'errorHeadersAuthFailed' => '2',
      'errorAuthFailed' => '3',
      'errorStatusAuthMissing' => '4',
      'errorHeadersAuthMissing' => '5',
      'errorAuthMissing' => '6',
      'errorStatusNoMatch' => '7',
      'errorHeadersNoMatch' => '8',
      'errorNoMatch' => '9',
      'errorStatusLimitsExceeded' => '10',
      'errorHeadersLimitsExceeded' => '11',
      'errorLimitsExceeded' => '12'
    }
  end

  let(:limit_01) do
    {
      'period' => 'eternity',
      'value' => 1000,
      'metricMethodRef' => {
        'systemName' => 'hits',
      }
    }
  end

  let(:pricing_rule_01) do
    {
      'from' => 1,
      'to' => 1000,
      'pricePerUnit' => 1,
      'metricMethodRef' => {
        'systemName' => 'hits',
      }
    }
  end

  let(:basic_plan) do
    {
      'name' => "Basic Plan",
      'appsRequireApproval' => true,
      'trialPeriod' => 0,
      'setupFee' => 0,
      'custom' => false,
      'state' => 'hidden',
      'costMonth' => 0,
      'pricingRules' => [pricing_rule_01],
      'limits' => [limit_01]
    }
  end

  let(:plans) { { 'basic' => basic_plan } }

  let(:backend_usages) do
    {
      'backend_01' => { 'path' => '/v1' },
      'backend_02' => { 'path' => '/v2' },
    }
  end

  let(:apicast_policy) do
    {
      'name' => 'apicast',
      'version' => 'builtin',
      'configuration' => {},
      'enabled' => true,
    }
  end

  let(:policy_chain) { [apicast_policy] }

  let(:security) { { 'hostHeader' => 'my_hostname', 'secretToken' => 'my_secret_token' } }

  let(:deployment) do
    {
      'apicastSelfManaged' => {
        'authentication' => {
          'userkey' => {
            'authUserKey' => 'my_user_key',
            'credentials' => 'mycredentials',
            'security' => security,
            'gatewayResponse' => gateway_response,
          }
        }
      }
    }
  end
  let(:product_raw_base) do
    {
      'apiVersion' => 'capabilities.3scale.net/v1beta1',
      'kind' => 'Product',
      'metadata' => {},
      'spec' => {
        'systemName' => system_name,
        'name' => name,
        'description' => description,
        'methods' => methods,
        'metrics' => metrics,
        'mappingRules' => mapping_rules,
        'deployment' => deployment,
        'applicationPlans' => plans,
        'backendUsages' => backend_usages,
        'policies' => policy_chain,
      }
    }
  end

  let(:backend_01_raw_base) do
    {
      'apiVersion' => 'capabilities.3scale.net/v1beta1',
      'kind' => 'Backend',
      'metadata' => {},
      'spec' => {
        'systemName' => 'backend_01',
        'privateBaseURL' => 'https://b1.example.com',
        'name' => 'Backend 01',
        'description' => 'some desc',
        'methods' => backend_01_methods,
        'metrics' => backend_01_metrics,
        'mappingRules' => backend_01_mapping_rules,
      }
    }
  end

  let(:backend_02_raw_base) do
    {
      'apiVersion' => 'capabilities.3scale.net/v1beta1',
      'kind' => 'Backend',
      'metadata' => {},
      'spec' => {
        'systemName' => 'backend_02',
        'privateBaseURL' => 'https://b2.example.com',
        'name' => 'Backend 02',
        'description' => 'some desc',
        'methods' => backend_02_methods,
        'metrics' => backend_02_metrics,
        'mappingRules' => backend_02_mapping_rules,
      }
    }
  end
  let(:product_raw) { product_raw_base }
  let(:backend_01_raw) { backend_01_raw_base }
  let(:backend_02_raw) { backend_02_raw_base }
  let(:product_raw_list) { [product_raw] }
  let(:backend_raw_list) { [backend_01_raw, backend_02_raw] }
  let(:products) { product_raw_list.map(&ThreeScaleToolbox::CRD::ProductParser.method(:new)) }
  let(:backends) { backend_raw_list.map(&ThreeScaleToolbox::CRD::BackendParser.method(:new)) }

  subject { described_class.new(products, backends) }

  context 'product metrics and methods not unique' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['metrics'] = {
          'mymetric01' => {
            'friendlyName' => 'my metric01',
            'unit' => '1',
            'description' => 'mymetric01 desc',
          },
        }
        new['spec']['methods'] = {
          'mymetric01' => {
            'friendlyName' => 'my metric01',
            'description' => 'mymetric01 desc',
          },
        }
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /metrics and method system names that are not unique/)
    end
  end

  context 'product mapping rules have wrong ref' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['mappingRules'] = [
          {
            'httpMethod' => 'GET',
            'pattern' => '/v1/pets',
            'increment' => 1,
            'last' => true,
            'metricMethodRef' => 'unknownref'
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /referencing to metric unknownref has not been found/)
    end
  end

  context 'product backend usages wrong ref' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['backendUsages'] = { 'unknownref' => { 'path' => '/v1' } }
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /backend usage reference to backend unknownref has not been found/)
    end
  end

  context 'plan limit wrong backend reference' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['applicationPlans']['basic']['limits'] = [
          {
            'period' => 'eternity',
            'value' => 1000,
            'metricMethodRef' => {
              'systemName' => 'some_system_name',
              'backend' => 'unknownref',
            }
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /the backend unknownref has not been found in backend usages/)
    end
  end

  context 'plan limit wrong backend metric reference' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['applicationPlans']['basic']['limits'] = [
          {
            'period' => 'eternity',
            'value' => 1000,
            'metricMethodRef' => {
              'systemName' => 'unknownref',
              'backend' => 'backend_01',
            }
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /the metric unknownref has not been found in backend backend_01/)
    end
  end

  context 'plan limit wrong metric reference' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['applicationPlans']['basic']['limits'] = [
          {
            'period' => 'eternity',
            'value' => 1000,
            'metricMethodRef' => {
              'systemName' => 'unknownref',
            }
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /the metric unknownref has not been found/)
    end
  end

  context 'plan pricing rule wrong backend reference' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['applicationPlans']['basic']['pricingRules'] = [
          {
            'from' => 1,
            'to' => 10,
            'pricePerUnit' => 1,
            'metricMethodRef' => {
              'systemName' => 'some_system_name',
              'backend' => 'unknownref',
            }
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /the backend unknownref has not been found in backend usages/)
    end
  end

  context 'plan pricing rule wrong backend metric reference' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['applicationPlans']['basic']['pricingRules'] = [
          {
            'from' => 1,
            'to' => 10,
            'pricePerUnit' => 1,
            'metricMethodRef' => {
              'systemName' => 'unknownref',
              'backend' => 'backend_01',
            }
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /the metric unknownref has not been found in backend backend_01/)
    end
  end

  context 'plan pricing rule wrong metric reference' do
    let(:product_raw) do
      product_raw_base.clone.tap do |new|
        new['spec']['applicationPlans']['basic']['pricingRules'] = [
          {
            'from' => 1,
            'to' => 10,
            'pricePerUnit' => 1,
            'metricMethodRef' => {
              'systemName' => 'unknownref',
            }
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /the metric unknownref has not been found/)
    end
  end

  context 'backend metrics and methods not unique' do
    let(:backend_01_raw) do
      backend_01_raw_base.clone.tap do |new|
        new['spec']['metrics'] = {
          'mymetric01' => {
            'friendlyName' => 'my metric01',
            'unit' => '1',
            'description' => 'mymetric01 desc',
          },
        }
        new['spec']['methods'] = {
          'mymetric01' => {
            'friendlyName' => 'my metric01',
            'description' => 'mymetric01 desc',
          },
        }
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Backend backend_01 contains metrics and method system names that are not unique/)
    end
  end

  context 'backend mapping rules have wrong ref' do
    let(:backend_01_raw) do
      backend_01_raw_base.clone.tap do |new|
        new['spec']['mappingRules'] = [
          {
            'httpMethod' => 'GET',
            'pattern' => '/v1/pets',
            'increment' => 1,
            'last' => true,
            'metricMethodRef' => 'unknownref'
          }
        ]
      end
    end

    it 'raise error' do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /referencing to metric unknownref has not been found/)
    end
  end

  context '#list_services' do
    it 'one product is listed' do
      expect(subject.list_services(page: nil, per_page: nil).length).to eq 1
    end
  end

  let(:product_id) { subject.list_services(page: nil, per_page: nil)[0].fetch('id') }

  context '#show_service' do
    it 'expected attrs' do
      expect(subject.show_service(product_id)).to include('name' => name)
      expect(subject.show_service(product_id)).to include('system_name' => system_name)
      expect(subject.show_service(product_id)).to include('deployment_option' => 'self_managed')
      expect(subject.show_service(product_id)).to include('backend_version' => '1')
    end
  end

  context '#list_backend_usages' do
    it 'backend 01 returned' do
      expect(subject.list_backend_usages(product_id).find { |bu| bu.fetch('path') == '/v1' }).not_to be_nil
    end

    it 'backend 02 returned' do
      expect(subject.list_backend_usages(product_id).find { |bu| bu.fetch('path') == '/v2' }).not_to be_nil
    end
  end

  let(:backend_01_id) do
    subject.list_backend_usages(product_id).find { |bu| bu.fetch('path') == '/v1' }.fetch('backend_id')
  end

  let(:backend_02_id) do
    subject.list_backend_usages(product_id).find { |bu| bu.fetch('path') == '/v2' }.fetch('backend_id')
  end

  context '#backend' do
    it 'backend_01 expected attrs' do
      expect(subject.backend(backend_01_id)).to include('name' => 'Backend 01')
      expect(subject.backend(backend_01_id)).to include('system_name' => 'backend_01')
      expect(subject.backend(backend_01_id)).to include('private_endpoint' => 'https://b1.example.com')
    end

    it 'backend_02 expected attrs' do
      expect(subject.backend(backend_02_id)).to include('name' => 'Backend 02')
      expect(subject.backend(backend_02_id)).to include('system_name' => 'backend_02')
      expect(subject.backend(backend_02_id)).to include('private_endpoint' => 'https://b2.example.com')
    end
  end

  context '#list_backend_metrics' do
    it 'expected attrs' do
      expect(subject.list_backend_metrics(backend_01_id).map { |m| m.fetch('system_name') }).to match_array(backend_01_metrics.keys + backend_01_methods.keys)
      expect(subject.list_backend_metrics(backend_02_id).map { |m| m.fetch('system_name') }).to match_array(backend_02_metrics.keys + backend_02_methods.keys)
      expect(subject.list_backend_metrics(backend_01_id).map { |m| m.fetch('friendly_name') }).to match_array((backend_01_metrics.values + backend_01_methods.values).map { |m| m.fetch('friendlyName') })
      expect(subject.list_backend_metrics(backend_02_id).map { |m| m.fetch('friendly_name') }).to match_array((backend_02_metrics.values + backend_02_methods.values).map { |m| m.fetch('friendlyName') })
    end
  end

  context '#list_backend_methods' do
    it 'expected attrs' do
      expect(subject.list_backend_methods(backend_01_id, 1).map { |m| m.fetch('system_name') }).to match_array(backend_01_methods.keys)
      expect(subject.list_backend_methods(backend_02_id, 1).map { |m| m.fetch('system_name') }).to match_array(backend_02_methods.keys)
      expect(subject.list_backend_methods(backend_01_id, 1).map { |m| m.fetch('friendly_name') }).to match_array(backend_01_methods.values.map { |m| m.fetch('friendlyName') })
      expect(subject.list_backend_methods(backend_02_id, 1).map { |m| m.fetch('friendly_name') }).to match_array(backend_02_methods.values.map { |m| m.fetch('friendlyName') })
    end
  end

  context '#list_backend_mapping_rules' do
    let(:metric_index) do
      subject.list_backend_metrics(backend_01_id).each_with_object({}) { |metric, hash| hash[metric.fetch('id')] = metric.fetch('system_name') }
    end
    it 'expected attrs' do
      expect(subject.list_backend_mapping_rules(backend_01_id).map { |m| m.fetch('pattern') }).to match_array(backend_01_mapping_rules.map { |mr| mr.fetch('pattern') } )
      expect(subject.list_backend_mapping_rules(backend_01_id).map { |m| metric_index.fetch(m.fetch('metric_id')) }).to match_array(backend_01_mapping_rules.map { |mr| mr.fetch('metricMethodRef') } )
    end
  end

  context '#show_proxy' do
    it 'expected attrs' do
      expect(subject.show_proxy(product_id)).to include('auth_user_key' => 'my_user_key')
      expect(subject.show_proxy(product_id)).to include('credentials_location' => 'mycredentials')
    end
  end

  context '#show_oidc' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'oidc' => {
              'authenticationFlow' => {
                'standardFlowEnabled' => true,
                'implicitFlowEnabled' => true,
                'serviceAccountsEnabled' => true,
                'directAccessGrantsEnabled' => true,
              }
            }
          }
        }
      }
    end
    it 'expected attrs' do
      expect(subject.show_oidc(product_id)).to include('standard_flow_enabled' => true)
      expect(subject.show_oidc(product_id)).to include('implicit_flow_enabled' => true)
      expect(subject.show_oidc(product_id)).to include('service_accounts_enabled' => true)
      expect(subject.show_oidc(product_id)).to include('direct_access_grants_enabled' => true)
    end
  end

  context '#list_metrics' do
    it 'expected attrs' do
      expect(subject.list_metrics(product_id).map { |m| m.fetch('system_name') }).to match_array(metrics.keys + methods.keys)
      expect(subject.list_metrics(product_id).map { |m| m.fetch('friendly_name') }).to match_array((metrics.values + methods.values).map { |m| m.fetch('friendlyName') })
    end
  end

  context '#list_methods' do
    it 'expected attrs' do
      expect(subject.list_methods(product_id, 1).map { |m| m.fetch('system_name') }).to match_array(methods.keys)
      expect(subject.list_methods(product_id, 1).map { |m| m.fetch('friendly_name') }).to match_array((methods.values).map { |m| m.fetch('friendlyName') })
    end
  end

  context '#list_mapping_rules' do
    let(:metric_index) do
      subject.list_metrics(product_id).each_with_object({}) { |metric, hash| hash[metric.fetch('id')] = metric.fetch('system_name') }
    end

    it 'expected attrs' do
      expect(subject.list_mapping_rules(product_id).map { |m| m.fetch('pattern') }).to match_array(mapping_rules.map { |mr| mr.fetch('pattern') } )
      expect(subject.list_mapping_rules(product_id).map { |m| metric_index.fetch(m.fetch('metric_id')) }).to match_array(mapping_rules.map { |mr| mr.fetch('metricMethodRef') } )
    end
  end

  context '#list_service_application_plans' do
    it 'expected attrs' do
      expect(subject.list_service_application_plans(product_id).map { |p| p.fetch('system_name') }).to match_array(plans.keys)
      expect(subject.list_service_application_plans(product_id).map { |p| p.fetch('name') }).to match_array(plans.values.map { |p| p.fetch('name') } )
    end
  end

  let(:plan_id) { subject.list_service_application_plans(product_id)[0].fetch('id') }

  context '#list_application_plan_limits' do
    let(:metric_index) do
      subject.list_metrics(product_id).each_with_object({}) { |metric, hash| hash[metric.fetch('id')] = metric.fetch('system_name') }
    end

    it 'expected attrs' do
      expect(subject.list_application_plan_limits(plan_id).map { |p| p.fetch('period') }).to match_array(basic_plan.fetch('limits').map { |l| l.fetch('period') })
      expect(subject.list_application_plan_limits(plan_id).map { |p| p.fetch('value') }).to match_array(basic_plan.fetch('limits').map { |l| l.fetch('value') })
      expect(subject.list_application_plan_limits(plan_id).map { |p| metric_index.fetch(p.fetch('metric_id')) }).to match_array(basic_plan.fetch('limits').map { |l| l.dig('metricMethodRef', 'systemName') })
    end
  end

  context '#show_policies' do
    it 'expected attrs' do
      expect(subject.show_policies(product_id).map { |p| p.fetch('name') }).to match_array(policy_chain.map { |p| p.fetch('name') })
      expect(subject.show_policies(product_id).map { |p| p.fetch('version') }).to match_array(policy_chain.map { |p| p.fetch('version') })
      expect(subject.show_policies(product_id).map { |p| p.fetch('configuration') }).to match_array(policy_chain.map { |p| p.fetch('configuration') })
      expect(subject.show_policies(product_id).map { |p| p.fetch('enabled') }).to match_array(policy_chain.map { |p| p.fetch('enabled') })
    end
  end

  context '#list_pricingrules_per_application_plan' do
    let(:metric_index) do
      subject.list_metrics(product_id).each_with_object({}) { |metric, hash| hash[metric.fetch('id')] = metric.fetch('system_name') }
    end

    it 'expected attrs' do
      expect(subject.list_pricingrules_per_application_plan(plan_id).map { |p| p.fetch('min') }).to match_array(basic_plan.fetch('pricingRules').map { |l| l.fetch('from') })
      expect(subject.list_pricingrules_per_application_plan(plan_id).map { |p| p.fetch('max') }).to match_array(basic_plan.fetch('pricingRules').map { |l| l.fetch('to') })
      expect(subject.list_pricingrules_per_application_plan(plan_id).map { |p| p.fetch('cost_per_unit') }).to match_array(basic_plan.fetch('pricingRules').map { |l| l.fetch('pricePerUnit') })
      expect(subject.list_pricingrules_per_application_plan(plan_id).map { |p| metric_index.fetch(p.fetch('metric_id')) }).to match_array(basic_plan.fetch('pricingRules').map { |l| l.dig('metricMethodRef', 'systemName') })
    end
  end
end
