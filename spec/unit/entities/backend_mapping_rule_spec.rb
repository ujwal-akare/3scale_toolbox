RSpec.describe ThreeScaleToolbox::Entities::BackendMappingRule do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'backend') }
  let(:backend_id) { 100 }

  before :each do
    allow(backend).to receive(:id).and_return(backend_id)
    allow(backend).to receive(:remote).and_return(remote)
  end

  context 'BackendMappingRule.create' do
    let(:attrs) { { 'pattern' => '/pets' } }
    subject { described_class.create(backend: backend, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_backend_mapping_rule).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:attrs) { { 'pattern' => '/pets', 'unexpected_param' => 3 } }
      let(:expected_attrs) { { 'pattern' => '/pets' } }
      let(:rule_id) { 1 }
      let(:response) { { 'id' => rule_id, 'pattern' => '/pets' } }
      before :each do
        expect(remote).to receive(:create_backend_mapping_rule).with(backend_id, expected_attrs).and_return(response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq rule_id
      end
    end
  end

  context 'instance method' do
    let(:rule_id) { 999 }
    let(:metric_id) { 888 }
    let(:attrs) do
      {
        'id' => rule_id,
        'pattern' => '/pets',
        'delta' => 1,
        'last' => true,
        'metric_id' => metric_id,
        'http_method' => 'GET'
      }
    end
    let(:mapping_rule) { described_class.new(id: rule_id, backend: backend, attrs: attrs) }

    context '#attrs' do
      subject { mapping_rule.attrs }

      context 'when no attrs available' do
        let(:attrs) { nil }
        let(:remote_response) do
          {
            'id' => rule_id,
            'pattern' => '/pets',
            'delta' => 1,
            'metric_id' => metric_id,
            'http_method' => 'GET'
          }
        end

        it 'remote fecth' do
          expect(remote).to receive(:backend_mapping_rule).with(backend_id, rule_id).and_return(remote_response)
          is_expected.to eq(remote_response)
        end
      end

      it 'attrs are available' do
        is_expected.to eq(attrs)
      end
    end

    context '#metric_id' do
      subject { mapping_rule.metric_id }

      it 'returns metric_id' do
        is_expected.to eq metric_id
      end
    end

    context '#update' do
      let(:new_pattern) { '/new_pattern' }
      let(:new_attrs) { { 'pattern' => new_pattern, 'unexpected_attrs': 3 } }
      subject { mapping_rule.update(new_attrs) }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:update_backend_mapping_rule).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:expected_attrs) { { 'pattern' => new_pattern } }
        let(:remote_response) do
          {
            'id' => rule_id,
            'pattern' => new_pattern,
            'delta' => 1,
            'metric_id' => metric_id,
            'http_method' => 'GET'
          }
        end

        before :each do
          expect(remote).to receive(:update_backend_mapping_rule).with(backend_id, rule_id, expected_attrs).and_return(remote_response)
        end

        it 'new attrs returned' do
          is_expected.to eq(remote_response)
          expect(mapping_rule.attrs).to include(expected_attrs)
        end
      end
    end

    context '#delete' do
      subject { mapping_rule.delete }

      before :each do
        expect(remote).to receive(:delete_backend_mapping_rule).with(backend_id, rule_id).and_return(true)
      end

      it 'remote call done' do
        is_expected.to be_truthy
      end
    end

    context '#to_cr' do
      let(:metric_01) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'metric_01') }

      subject { mapping_rule.to_cr }

      before :each do
        allow(metric_01).to receive(:id).and_return(metric_id)
        allow(metric_01).to receive(:system_name).and_return('metric_01')
        allow(backend).to receive(:system_name).and_return('backend01')
        allow(backend).to receive(:methods).and_return([])
        allow(backend).to receive(:metrics).and_return([metric_01])
      end

      it 'expected httpMethod' do
        expect(subject).to include('httpMethod' => 'GET')
      end

      it 'expected pattern' do
        expect(subject).to include('pattern' => '/pets')
      end

      it 'expected metricMethodRef' do
        expect(subject).to include('metricMethodRef' => 'metric_01')
      end

      it 'expected increment' do
        expect(subject).to include('increment' => 1)
      end

      it 'expected last' do
        expect(subject).to include('last' => true)
      end

      context 'metric ref not found' do
        before :each do
          allow(backend).to receive(:metrics).and_return([])
        end
        it 'error raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::Error, /metric id #{metric_id}/)
        end
      end
    end
  end
end
