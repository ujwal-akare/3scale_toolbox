RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ValidatePlanStep do
  let(:artifacts_resource) { { } }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:backend_01) { instance_double(ThreeScaleToolbox::Entities::Backend, 'backend_01') }
  let(:backend_02) { instance_double(ThreeScaleToolbox::Entities::Backend, 'backend_02') }
  let(:backend_usage_01) { instance_double(ThreeScaleToolbox::Entities::BackendUsage, 'backend_usage_01') }
  let(:backend_usage_02) { instance_double(ThreeScaleToolbox::Entities::BackendUsage, 'backend_usage_02') }
  let(:backend_usage_list) { [backend_usage_01, backend_usage_02] }
  let(:context) do
    {
      service: service,
      artifacts_resource: artifacts_resource
    }
  end
  subject { described_class.new(context).call }

  before :example do
    allow(service).to receive(:backend_usage_list).and_return(backend_usage_list)
    allow(backend_01).to receive(:system_name).and_return('backend_01')
    allow(backend_usage_01).to receive(:backend).and_return(backend_01)
    allow(backend_02).to receive(:system_name).and_return('backend_02')
    allow(backend_usage_02).to receive(:backend).and_return(backend_02)
  end

  context 'duplicated system_name in product metrics' do
    let(:artifacts_resource) do
      {
        'metrics' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'unit' => 'hit'
          },
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits2',
            'description' => 'Number of API hits',
            'unit' => 'hit'
          },
          {
            'system_name' => 'other',
            'friendly_name' => 'Other',
            'description' => 'Number of API other',
            'unit' => '1'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Product metrics and method system names must be unique/)
    end
  end

  context 'duplicated system_name in product methods' do
    let(:artifacts_resource) do
      {
        'methods' => [
          {
            'system_name' => 'method01',
            'friendly_name' => 'Method 01',
            'description' => 'Method 01',
            'parent_id' => '12345'
          },
          {
            'system_name' => 'method01',
            'friendly_name' => 'Method 01',
            'description' => 'Method 01',
            'parent_id' => '12345'
          },
          {
            'system_name' => 'other',
            'friendly_name' => 'Other',
            'description' => 'Number of API other',
            'parent_id' => '12345'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Product metrics and method system names must be unique/)
    end
  end

  context 'duplicated sytem_name in product metrics and methods' do
    let(:artifacts_resource) do
      {
        'metrics' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'unit' => 'hit'
          }
        ],
        'methods' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'parent_id' => '12345'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Product metrics and method system names must be unique/)
    end
  end

  context 'duplicated system_name in backend metrics' do
    let(:artifacts_resource) do
      {
        'metrics' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'unit' => 'hit',
            'backend_system_name' => 'backend_01'
          },
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits2',
            'description' => 'Number of API hits',
            'unit' => 'hit',
            'backend_system_name' => 'backend_01'
          },
          {
            'system_name' => 'other',
            'friendly_name' => 'Other',
            'description' => 'Number of API other',
            'unit' => '1',
            'backend_system_name' => 'backend_01'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Backend backend_01 contains metrics and method system names that are not unique/)
    end
  end

  context 'duplicated system_name in backend methods' do
    let(:artifacts_resource) do
      {
        'methods' => [
          {
            'system_name' => 'method01',
            'friendly_name' => 'Method 01',
            'description' => 'Method 01',
            'parent_id' => '12345',
            'backend_system_name' => 'backend_01'
          },
          {
            'system_name' => 'method01',
            'friendly_name' => 'Method 01',
            'description' => 'Method 01',
            'parent_id' => '12345',
            'backend_system_name' => 'backend_01'
          },
          {
            'system_name' => 'other',
            'friendly_name' => 'Other',
            'description' => 'Number of API other',
            'parent_id' => '12345',
            'backend_system_name' => 'backend_01'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Backend backend_01 contains metrics and method system names that are not unique/)
    end
  end

  context 'duplicated sytem_name in backend metrics and methods' do
    let(:artifacts_resource) do
      {
        'metrics' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'unit' => 'hit',
            'backend_system_name' => 'backend_01'
          }
        ],
        'methods' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'parent_id' => '12345',
            'backend_system_name' => 'backend_01'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Backend backend_01 contains metrics and method system names that are not unique/)
    end
  end

  context 'duplicated sytem_name but in different backends' do
    let(:artifacts_resource) do
      {
        'metrics' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'unit' => 'hit',
            'backend_system_name' => 'backend_01'
          }
        ],
        'methods' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'parent_id' => '12345',
            'backend_system_name' => 'backend_02'
          }
        ]
      }
    end

    it 'does not raise error' do
      subject
    end
  end

  context 'backend not in backend usages' do
    let(:artifacts_resource) do
      {
        'metrics' => [
          {
            'system_name' => 'hits',
            'friendly_name' => 'Hits',
            'description' => 'Number of API hits',
            'unit' => 'hit',
            'backend_system_name' => 'unknown_backend'
          }
        ],
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Backend usage reference/)
    end
  end

  context 'limit with backend metric not in metric list' do
    let(:artifacts_resource) do
      {
        'limits' => [
          {
            'period' => 'eternity', 'value' => 123, 'plan_id' => 2357356305347,
            'metric_system_name' => 'unknown_metric',
            'metric_backend_system_name' => 'backend_01'
          }
        ],
        'metrics' => [
          {
            'system_name' => 'hits', 'friendly_name' => 'Hits',
            'description' => 'Number of API hits', 'unit' => 'hit',
            'backend_system_name' => 'backend_01'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Limit with backend metric/)
    end
  end

  context 'limit with product metric not in metric list' do
    let(:artifacts_resource) do
      {
        'limits' => [
          {
            'period' => 'eternity', 'value' => 123, 'plan_id' => 2357356305347,
            'metric_system_name' => 'unknown_metric',
          }
        ],
        'metrics' => [
          {
            'system_name' => 'hits', 'friendly_name' => 'Hits',
            'description' => 'Number of API hits', 'unit' => 'hit',
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /Limit with product metric/)
    end
  end

  context 'pricingrule with backend metric not in metric list' do
    let(:artifacts_resource) do
      {
        'pricingrules' => [
          {
            'cost_per_unit' => '0.0', 'min' => 1, 'max' => 12,
            'metric_system_name' => 'unknown_metric',
            'metric_backend_system_name' => 'backend_01'
          }
        ],
        'metrics' => [
          {
            'system_name' => 'hits', 'friendly_name' => 'Hits',
            'description' => 'Number of API hits', 'unit' => 'hit',
            'backend_system_name' => 'backend_01'
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /PricingRule with backend metric/)
    end
  end

  context 'pricingrule with product metric not in metric list' do
    let(:artifacts_resource) do
      {
        'pricingrules' => [
          {
            'cost_per_unit' => '0.0', 'min' => 1, 'max' => 12,
            'metric_system_name' => 'unknown_metric',
          }
        ],
        'metrics' => [
          {
            'system_name' => 'hits', 'friendly_name' => 'Hits',
            'description' => 'Number of API hits', 'unit' => 'hit',
          }
        ]
      }
    end

    it do
      expect { subject }.to raise_error(ThreeScaleToolbox::Error, /PricingRule with product metric/)
    end
  end
end
