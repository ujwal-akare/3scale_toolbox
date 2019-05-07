RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Export::WriteArtifactsStep do
  include_context :temp_dir

  let(:result_plan) { {} }
  let(:result_limits) { [] }
  let(:result_pricingrules) { [] }
  let(:result_plan_features) { [] }
  let(:result_plan_metrics) { {} }
  let(:result_plan_methods) { {} }
  let(:result) do
    {
      plan: result_plan,
      limits: result_limits,
      pricingrules: result_pricingrules,
      plan_features: result_plan_features,
      plan_metrics: result_plan_metrics,
      plan_methods: result_plan_methods
    }
  end
  let(:file) {}
  let(:context) { { result: result, file: file } }
  subject { described_class.new(context) }

  context '#call' do
    context 'when file selected' do
      let(:file) { tmp_dir.join('plan.yaml') }

      it 'content is written to the file' do
        subject.call
        expect(file.read.size).to be_positive
      end

      it 'expected keys are written to the file' do
        subject.call
        expected_keys = %w[plan limits pricingrules plan_features
                           metrics methods created_at toolbox_version]
        expect(YAML.safe_load(file.read)).to include(*expected_keys)
      end
    end

    context 'when stdout selected' do
      it 'content is written to the stdout' do
        expect { subject.call }.to output.to_stdout
      end
    end

    context 'serialized plan attributes' do
      let(:file) { tmp_dir.join('plan.yaml') }
      let(:result_plan) do
        { 'allowed_key' => 1, 'id' => 1, 'links' => [], 'created_at' => 'date', 'updated_at' => 'date' }
      end
      let(:serialized_plan) { YAML.safe_load(file.read)['plan'] }

      it 'not blacklisted are allowed' do
        subject.call
        expect(serialized_plan).to include('allowed_key' => 1)
      end

      it 'blacklisted are filtered' do
        subject.call
        expect(serialized_plan).not_to include('id', 'links', 'created_at', 'updated_at')
      end
    end

    context 'serialized plan limits attributes' do
      let(:file) { tmp_dir.join('plan.yaml') }
      let(:result_limits) do
        [
          {
            'allowed_key' => 1, 'metric' => { 'type' => 'metric', 'system_name' => 'metric_01' },
            'metric_id' => '1', 'links' => [], 'created_at' => 'date', 'updated_at' => 'date'
          }
        ]
      end
      let(:serialized_plan_limits) { YAML.safe_load(file.read)['limits'][0] }

      it 'include metric_system_name' do
        subject.call
        expect(serialized_plan_limits).to include('metric_system_name' => 'metric_01')
      end

      it 'not blacklisted are allowed' do
        subject.call
        expect(serialized_plan_limits).to include('allowed_key' => 1)
      end

      it 'blacklisted are filtered' do
        subject.call
        expect(serialized_plan_limits).not_to include('id', 'metric_id', 'links',
                                                      'created_at', 'updated_at')
      end
    end

    context 'serialized plan pricing rules attributes' do
      let(:file) { tmp_dir.join('plan.yaml') }
      let(:result_pricingrules) do
        [
          {
            'allowed_key' => 1, 'metric' => { 'type' => 'metric', 'system_name' => 'metric_01' },
            'metric_id' => '1', 'links' => [], 'created_at' => 'date', 'updated_at' => 'date'
          }
        ]
      end
      let(:serialized_plan_pr) { YAML.safe_load(file.read)['pricingrules'][0] }

      it 'include metric_system_name' do
        subject.call
        expect(serialized_plan_pr).to include('metric_system_name' => 'metric_01')
      end

      it 'not blacklisted are allowed' do
        subject.call
        expect(serialized_plan_pr).to include('allowed_key' => 1)
      end

      it 'blacklisted are filtered' do
        subject.call
        expect(serialized_plan_pr).not_to include('id', 'metric_id', 'links', 'created_at',
                                                  'updated_at')
      end
    end

    context 'serialized plan features attributes' do
      let(:file) { tmp_dir.join('plan.yaml') }
      let(:result_plan_features) do
        [
          {
            'allowed_key' => 1, 'id' => 1, 'links' => [],
            'created_at' => 'date', 'updated_at' => 'date'
          }
        ]
      end
      let(:serialized_plan_feature) { YAML.safe_load(file.read)['plan_features'][0] }

      it 'not blacklisted are allowed' do
        subject.call
        expect(serialized_plan_feature).to include('allowed_key' => 1)
      end

      it 'blacklisted are filtered' do
        subject.call
        expect(serialized_plan_feature).not_to include('id', 'links', 'created_at', 'updated_at')
      end
    end

    context 'serialized metrics attributes' do
      let(:file) { tmp_dir.join('plan.yaml') }
      let(:result_plan_metrics) do
        {
          '01' => {
            'allowed_key' => 1, 'id' => 1, 'links' => [],
            'created_at' => 'date', 'updated_at' => 'date'
          }
        }
      end
      let(:serialized_metric) { YAML.safe_load(file.read)['metrics'][0] }

      it 'not blacklisted are allowed' do
        subject.call
        expect(serialized_metric).to include('allowed_key' => 1)
      end

      it 'blacklisted are filtered' do
        subject.call
        expect(serialized_metric).not_to include('id', 'links', 'created_at', 'updated_at')
      end
    end

    context 'serialized methods attributes' do
      let(:file) { tmp_dir.join('plan.yaml') }
      let(:result_plan_methods) do
        {
          '01' => {
            'allowed_key' => 1, 'id' => 1, 'links' => [],
            'created_at' => 'date', 'updated_at' => 'date'
          }
        }
      end
      let(:serialized_method) { YAML.safe_load(file.read)['methods'][0] }

      it 'not blacklisted are allowed' do
        subject.call
        expect(serialized_method).to include('allowed_key' => 1)
      end

      it 'blacklisted are filtered' do
        subject.call
        expect(serialized_method).not_to include('id', 'links', 'created_at', 'updated_at')
      end
    end
  end
end
