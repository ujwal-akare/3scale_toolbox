RSpec.describe ThreeScaleToolbox::CRD::ProductParser do
  let(:system_name) { 'some_system_name' }
  let(:name) { 'some name' }
  let(:description) { 'some descr' }
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

  let(:plans) { {} }

  let(:backend_usages) { {} }

  let(:policy_chain) { [] }
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

  let(:cr) do
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

  let(:parser) { described_class.new cr }

  subject { parser }

  it 'system_name read' do
    expect(subject.system_name).to eq system_name
  end

  it 'name read' do
    expect(subject.name).to eq name
  end

  it 'description read' do
    expect(subject.description).to eq description
  end

  it 'hits metric read' do
    hits_metric = subject.metrics.find { |m| m.system_name == 'hits' }
    expect(hits_metric).not_to be_nil
    expect(hits_metric.friendly_name).to eq 'Hits'
    expect(hits_metric.unit).to eq 'hit'
    expect(hits_metric.description).to eq 'Number of API hits'
  end

  it 'mymetric01 metric read' do
    metric = subject.metrics.find { |m| m.system_name == 'mymetric01' }
    expect(metric).not_to be_nil
    expect(metric.friendly_name).to eq 'my metric01'
    expect(metric.unit).to eq '1'
    expect(metric.description).to eq 'mymetric01 desc'
  end

  it 'mymethod01 method read' do
    method = subject.methods.find { |m| m.system_name == 'mymethod01' }
    expect(method).not_to be_nil
    expect(method.friendly_name).to eq 'my method01'
    expect(method.description).to eq 'mymethod01 desc'
  end

  it 'mapping rule read' do
    expect(subject.mapping_rules).not_to be_nil
    expect(subject.mapping_rules.length).to eq 1
    expect(subject.mapping_rules[0].metric_ref).to eq 'mymethod01'
    expect(subject.mapping_rules[0].http_method).to eq 'GET'
    expect(subject.mapping_rules[0].pattern).to eq '/v1/pets'
    expect(subject.mapping_rules[0].delta).to eq 1
    expect(subject.mapping_rules[0].last).to be_truthy
  end

  it 'metric index correct' do
    expect(subject.metrics_index.keys).to contain_exactly('hits', 'mymetric01', 'mymethod01')
    expect(subject.metrics_index.fetch('hits').friendly_name).to eq 'Hits'
    expect(subject.metrics_index.fetch('mymetric01').friendly_name).to eq 'my metric01'
    expect(subject.metrics_index.fetch('mymethod01').friendly_name).to eq 'my method01'
  end

  context '#application_plans' do
    let(:plans) do
      {
        'basic' => {
          'name' => 'Basic',
          'appsRequireApproval' => false,
          'trialPeriod' => 1,
          'setupFee' => 1.5,
          'costMonth' => 4.5,
          'limits' => [
            {
              'period' => 'hour',
              'value' => 12345,
              'metricMethodRef' => {
                'systemName' => 'hits'
              }
            }
          ],
          'pricingRules' => [
            {
              'from' => 1,
              'to' => 1000,
              'pricePerUnit' => 3.5,
              'metricMethodRef' => {
                'systemName' => 'hits'
              }
            }
          ]
        },
        'unlimited' => {
          'name' => 'Unlimited',
          'appsRequireApproval' => true,
          'trialPeriod' => 2,
          'setupFee' => 3.5,
          'costMonth' => 4.5,
          'limits' => [
            {
              'period' => 'year',
              'value' => 12345,
              'metricMethodRef' => {
                'systemName' => 'backendmetric01',
                'backend' => 'backend01'
              }
            }
          ],
          'pricingRules' => [
            {
              'from' => 1,
              'to' => 1000,
              'pricePerUnit' => 3.5,
              'metricMethodRef' => {
                'systemName' => 'backendmetric01',
                'backend' => 'backend01'
              }
            }
          ]
        }
      }
    end

    subject { parser.application_plans }

    it 'basic plan read' do
      plan = subject.find { |m| m.system_name == 'basic' }
      expect(plan).not_to be_nil
      expect(plan.name).to eq 'Basic'
      expect(plan.approval_required).to be_falsy
      expect(plan.trial_period_days).to eq 1
      expect(plan.setup_fee).to eq 1.5
      expect(plan.cost_per_month).to eq 4.5
    end

    it 'basic plan limits read' do
      plan = subject.find { |m| m.system_name == 'basic' }
      expect(plan).not_to be_nil
      expect(plan.limits.length).to eq 1
      expect(plan.limits[0].period).to eq 'hour'
      expect(plan.limits[0].value).to eq 12345
      expect(plan.limits[0].metric_system_name).to eq 'hits'
      expect(plan.limits[0].backend_system_name).to be_nil
    end

    it 'basic plan pricing rules read' do
      plan = subject.find { |m| m.system_name == 'basic' }
      expect(plan).not_to be_nil
      expect(plan.pricing_rules.length).to eq 1
      expect(plan.pricing_rules[0].from).to eq 1
      expect(plan.pricing_rules[0].to).to eq 1000
      expect(plan.pricing_rules[0].price_per_unit).to eq 3.5
      expect(plan.pricing_rules[0].metric_system_name).to eq 'hits'
      expect(plan.pricing_rules[0].backend_system_name).to be_nil
    end

    it 'unlimited plan read' do
      plan = subject.find { |m| m.system_name == 'unlimited' }
      expect(plan).not_to be_nil
      expect(plan.name).to eq 'Unlimited'
      expect(plan.approval_required).to be_truthy
      expect(plan.trial_period_days).to eq 2
      expect(plan.setup_fee).to eq 3.5
      expect(plan.cost_per_month).to eq 4.5
    end

    it 'unlimited plan limits read' do
      plan = subject.find { |m| m.system_name == 'unlimited' }
      expect(plan).not_to be_nil
      expect(plan.limits.length).to eq 1
      expect(plan.limits[0].period).to eq 'year'
      expect(plan.limits[0].value).to eq 12345
      expect(plan.limits[0].metric_system_name).to eq 'backendmetric01'
      expect(plan.limits[0].backend_system_name).to eq 'backend01'
    end

    it 'unlimited plan pricing rules read' do
      plan = subject.find { |m| m.system_name == 'unlimited' }
      expect(plan).not_to be_nil
      expect(plan.pricing_rules.length).to eq 1
      expect(plan.pricing_rules[0].from).to eq 1
      expect(plan.pricing_rules[0].to).to eq 1000
      expect(plan.pricing_rules[0].price_per_unit).to eq 3.5
      expect(plan.pricing_rules[0].metric_system_name).to eq 'backendmetric01'
      expect(plan.pricing_rules[0].backend_system_name).to eq 'backend01'
    end
  end

  context '#backend_usages' do
    let(:backend_usages) do
      {
        'backend_01' => {
          'path' => '/v1/pets',
        },
        'backend_02' => {
          'path' => '/v1/cats',
        },
      }
    end

    subject { parser.backend_usages }

    it 'backend_01 usage read' do
      bu = subject.find { |b| b.backend_system_name == 'backend_01' }
      expect(bu).not_to be_nil
      expect(bu.path).to eq '/v1/pets'
    end

    it 'backend_02 usage read' do
      bu = subject.find { |b| b.backend_system_name == 'backend_02' }
      expect(bu).not_to be_nil
      expect(bu.path).to eq '/v1/cats'
    end
  end

  context '#policy_chain' do
    let(:apicast_configuration) { double('apicast_configuration') }
    let(:url_configuration) { double('url_configuration') }
    let(:policy_chain) do
      [
        {
          'name' => 'apicast',
          'version' => 'builtin',
          'enabled' => false,
          'configuration' => apicast_configuration
        },
        {
          'name' => 'url_rewriting',
          'version' => 'builtin',
          'enabled' => true,
          'configuration' => url_configuration
        }
      ]
    end

    subject { parser.policy_chain }

    it 'apicast policy read' do
      policy = subject.find { |p| p.name== 'apicast' }
      expect(policy).not_to be_nil
      expect(policy.version).to eq 'builtin'
      expect(policy.configuration).to eq apicast_configuration
      expect(policy.enabled).to be_falsy
    end

    it 'url policy read' do
      policy = subject.find { |p| p.name== 'url_rewriting' }
      expect(policy).not_to be_nil
      expect(policy.version).to eq 'builtin'
      expect(policy.configuration).to eq url_configuration
      expect(policy.enabled).to be_truthy
    end
  end

  context '#deployment_option hosted' do
    let(:deployment) do
      {
        'apicastHosted' => {
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

    subject { parser.deployment_option }

    it 'parsed' do
      is_expected.to eq 'hosted'
    end
  end

  context '#deployment_option self_managed' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'stagingPublicBaseURL' => 'https://staging.example.com',
          'productionPublicBaseURL' => 'https://.example.com',
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

    subject { parser.deployment_option }

    it 'parsed' do
      is_expected.to eq 'self_managed'
    end
  end

  context '#endpoint' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'stagingPublicBaseURL' => 'https://staging.example.com',
          'productionPublicBaseURL' => 'https://example.com',
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

    subject { parser.endpoint }

    it 'parsed' do
      is_expected.to eq 'https://example.com'
    end
  end

  context '#sandbox_endpoint' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'stagingPublicBaseURL' => 'https://staging.example.com',
          'productionPublicBaseURL' => 'https://.example.com',
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

    subject { parser.sandbox_endpoint }

    it 'parsed' do
      is_expected.to eq 'https://staging.example.com'
    end
  end

  context '#backend_version userkey' do
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

    subject { parser.backend_version }

    it 'parsed' do
      is_expected.to eq '1'
    end

    it '#auth_user_key' do
      expect(parser.auth_user_key).to eq 'my_user_key'
    end
  end

  context '#backend_version appidkey' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'appKeyAppID' => {
              'appID' => 'my_app_id',
              'appKey' => 'my_app_key',
              'credentials' => 'mycredentials',
              'security' => security,
              'gatewayResponse' => gateway_response,
            }
          }
        }
      }
    end

    subject { parser.backend_version }

    it 'parsed' do
      is_expected.to eq '2'
    end

    it '#auth_app_id' do
      expect(parser.auth_app_id).to eq 'my_app_id'
    end

    it '#auth_app_key' do
      expect(parser.auth_app_key).to eq 'my_app_key'
    end
  end

  context '#backend_version oidc' do
    let(:oidc_flow) do
      {
        'standardFlowEnabled' => true,
        'implicitFlowEnabled' => false,
        'serviceAccountsEnabled' => true,
        'directAccessGrantsEnabled' => false
      }
    end
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'oidc' => {
              'issuerType' => 'my_oidc_issuer_type',
              'issuerEndpoint' => 'my_oidc_endpoint',
              'jwtClaimWithClientID' => 'my_jwt_client_id',
              'jwtClaimWithClientIDType' => 'my_jwt_type',
              'credentials' => 'mycredentials',
              'security' => security,
              'authenticationFlow' => oidc_flow,
              'gatewayResponse' => gateway_response,
            }
          }
        }
      }
    end

    subject { parser.backend_version }

    it 'parsed' do
      is_expected.to eq 'oidc'
    end

    it '#oidc_issuer_type' do
      expect(parser.oidc_issuer_type).to eq 'my_oidc_issuer_type'
    end

    it '#oidc_issuer_endpoint' do
      expect(parser.oidc_issuer_endpoint).to eq 'my_oidc_endpoint'
    end

    it '#jwt_claim_with_client_id' do
      expect(parser.jwt_claim_with_client_id).to eq 'my_jwt_client_id'
    end

    it '#jwt_claim_with_client_id_type' do
      expect(parser.jwt_claim_with_client_id_type).to eq 'my_jwt_type'
    end

    it '#standard_flow_enabled' do
      expect(parser.standard_flow_enabled).to be_truthy
    end

    it '#implicit_flow_enabled' do
      expect(parser.implicit_flow_enabled).to be_falsy
    end

    it '#service_accounts_enabled' do
      expect(parser.service_accounts_enabled).to be_truthy
    end

    it '#direct_access_grants_enabled' do
      expect(parser.direct_access_grants_enabled).to be_falsy
    end
  end

  context '#secret_token' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'appKeyAppID' => {
              'appID' => 'my_app_id',
              'appKey' => 'my_app_key',
              'credentials' => 'mycredentials',
              'security' => security,
              'gatewayResponse' => gateway_response,
            }
          }
        }
      }
    end

    subject { parser.secret_token }

    it 'parsed' do
      is_expected.to eq 'my_secret_token'
    end
  end

  context '#hostname_rewrite' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'appKeyAppID' => {
              'appID' => 'my_app_id',
              'appKey' => 'my_app_key',
              'credentials' => 'mycredentials',
              'security' => security,
              'gatewayResponse' => gateway_response,
            }
          }
        }
      }
    end

    subject { parser.hostname_rewrite }

    it 'parsed' do
      is_expected.to eq 'my_hostname'
    end
  end

  context '#credentials_location' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'appKeyAppID' => {
              'appID' => 'my_app_id',
              'appKey' => 'my_app_key',
              'credentials' => 'mycredentials',
              'security' => security,
              'gatewayResponse' => gateway_response,
            }
          }
        }
      }
    end

    subject { parser.credentials_location }

    it 'parsed' do
      is_expected.to eq 'mycredentials'
    end
  end

  context 'gateway answer' do
    let(:deployment) do
      {
        'apicastSelfManaged' => {
          'authentication' => {
            'appKeyAppID' => {
              'appID' => 'my_app_id',
              'appKey' => 'my_app_key',
              'credentials' => 'mycredentials',
              'security' => security,
              'gatewayResponse' => gateway_response,
            }
          }
        }
      }
    end

    it '#error_auth_failed' do
      expect(parser.error_auth_failed).to eq '3'
    end

    it '#error_auth_missing' do
      expect(parser.error_auth_missing).to eq '6'
    end

    it '#error_status_auth_failed' do
      expect(parser.error_status_auth_failed).to eq '1'
    end

    it '#error_headers_auth_failed' do
      expect(parser.error_headers_auth_failed).to eq '2'
    end

    it '#error_status_auth_missing' do
      expect(parser.error_status_auth_missing).to eq '4'
    end

    it '#error_headers_auth_missing' do
      expect(parser.error_headers_auth_missing).to eq '5'
    end

    it '#error_no_match' do
      expect(parser.error_no_match).to eq '9'
    end

    it '#error_status_no_match' do
      expect(parser.error_status_no_match).to eq '7'
    end

    it '#error_headers_no_match' do
      expect(parser.error_headers_no_match).to eq '8'
    end

    it '#error_limits_exceeded' do
      expect(parser.error_limits_exceeded).to eq '12'
    end

    it '#error_status_limits_exceeded' do
      expect(parser.error_status_limits_exceeded).to eq '10'
    end

    it '#error_headers_limits_exceeded' do
      expect(parser.error_headers_limits_exceeded).to eq '11'
    end
  end
end
