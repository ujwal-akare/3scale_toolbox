RSpec.describe ThreeScaleToolbox::Entities::Backend do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }

  context 'Backend.create' do
    let(:attrs) { { 'name' => 'some name' } }
    subject { described_class.create(remote: remote, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_backend).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:attrs) { { 'name' => 'some name', 'unexpected_param' => 3 } }
      let(:expected_attrs) { { 'name' => 'some name' } }
      let(:response) { { 'id' => 1, 'name' => 'some name' } }
      before :each do
        expect(remote).to receive(:create_backend).with(expected_attrs).and_return(response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq 1
      end
    end
  end

  context 'Backend.find' do
    let(:ref) { 1234 }
    subject { described_class.find(remote: remote, ref: ref) }

    context 'when backend does not exist' do
      before :each do
        expect(remote).to receive(:backend).with(ref).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:list_backends).and_return([])
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when backend is found by id' do
      before :each do
        expect(remote).to receive(:backend).with(ref).and_return('id' => ref)
      end

      it 'instance is returned' do
        expect(subject.id).to eq ref
      end
    end

    context 'when backend is found by system_name' do
      let(:ref) { 'some_system_name' }
      before :each do
        expect(remote).to receive(:list_backends).and_return([{ 'id' => 1, 'system_name' => ref }])
      end

      it 'instance is returned' do
        expect(subject.id).to eq 1
      end
    end
  end

  context 'Backend.find_by_system_name' do
    let(:system_name) { 'some_system_name' }
    subject { described_class.find_by_system_name(remote: remote, system_name: system_name) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:list_backends).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when backend is not found' do
      before :each do
        expect(remote).to receive(:list_backends).and_return([])
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when backend is found' do
      before :each do
        expect(remote).to receive(:list_backends).and_return([{ 'id' => 1, 'system_name' => system_name }])
      end

      it 'instance is returned' do
        expect(subject.id).to eq 1
      end
    end

    context 'when backend list length is' do
      let(:expected_backend_id) { 0 }

      context 'MAX_BACKENDS_PER_PAGE - 1' do
        let(:backend_response) do
          # the latest backend is the one with the searched system_name
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE - 2).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end + [{ 'id' => expected_backend_id, 'system_name' => system_name }]
        end

        it 'then 1 remote call' do
          expect(remote).to receive(:list_backends).with(page: 1, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response)

          expect(subject.id).to eq expected_backend_id
        end
      end

      context 'MAX_BACKENDS_PER_PAGE' do
        let(:backend_response01) do
          # the latest backend is the one with the searched system_name
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE - 1).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end + [{ 'id' => expected_backend_id, 'system_name' => system_name }]
        end
        let(:backend_response02) { [] }

        it 'then 2 remote call' do
            expect(remote).to receive(:list_backends).with(page: 1, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response01)
            expect(remote).to receive(:list_backends).with(page: 2, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response02)

            expect(subject.id).to eq expected_backend_id
        end
      end

      context 'MAX_BACKENDS_PER_PAGE + 1' do
        let(:backend_response01) do
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end
        end
        # the latest backend is the one with the searched system_name
        let(:backend_response02) { [{ 'id' => expected_backend_id, 'system_name' => system_name }] }

        it 'then 2 remote call' do
            expect(remote).to receive(:list_backends).with(page: 1, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response01)
            expect(remote).to receive(:list_backends).with(page: 2, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response02)

            expect(subject.id).to eq expected_backend_id
        end
      end

      context '2 * MAX_BACKENDS_PER_PAGE' do
        let(:backend_response01) do
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end
        end
        let(:backend_response02) do
          # the latest backend is the one with the searched system_name
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE - 1).map do |idx|
            { 'id' => ThreeScale::API::MAX_BACKENDS_PER_PAGE + idx, 'system_name' => (ThreeScale::API::MAX_BACKENDS_PER_PAGE + idx).to_s }
          end + [{ 'id' => expected_backend_id, 'system_name' => system_name }]
        end
        let(:backend_response03) { [] }

        it 'then 3 remote call' do
            expect(remote).to receive(:list_backends).with(page: 1, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response01)
            expect(remote).to receive(:list_backends).with(page: 2, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response02)
            expect(remote).to receive(:list_backends).with(page: 3, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response03)

            expect(subject.id).to eq expected_backend_id
        end
      end

      context '2 * MAX_BACKENDS_PER_PAGE + 1' do
        let(:backend_response01) do
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end
        end
        let(:backend_response02) do
          # the latest backend is the one with the searched system_name
          (1..ThreeScale::API::MAX_BACKENDS_PER_PAGE).map do |idx|
            { 'id' => ThreeScale::API::MAX_BACKENDS_PER_PAGE + idx, 'system_name' => (ThreeScale::API::MAX_BACKENDS_PER_PAGE + idx).to_s }
          end
        end
        let(:backend_response03) { [{ 'id' => expected_backend_id, 'system_name' => system_name }] }

        it 'then 3 remote call' do
            expect(remote).to receive(:list_backends).with(page: 1, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response01)
            expect(remote).to receive(:list_backends).with(page: 2, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response02)
            expect(remote).to receive(:list_backends).with(page: 3, per_page: ThreeScale::API::MAX_BACKENDS_PER_PAGE).and_return(backend_response03)

            expect(subject.id).to eq expected_backend_id
        end
      end
    end
  end

  context 'instance method' do
    let(:backend_id) { 99 }
    let(:backend) { described_class.new(id: backend_id, remote: remote, attrs: attrs) }
    let(:attrs) { { 'id' => backend_id, 'name' => 'some name' } }

    context '#attrs' do
      subject { backend.attrs }

      context 'when no attrs available' do
        let(:attrs) { nil }
        let(:remote_reponse) { { 'id' => backend_id, 'name' => 'some name' } }
        before :each do
          expect(remote).to receive(:backend).with(backend_id).and_return(remote_reponse)
        end

        it 'fetch remote attrs' do
          is_expected.to eq(remote_reponse)
        end
      end

      context 'when attrs are available' do
        it 'they are returned' do
          is_expected.to eq(attrs)
        end
      end
    end

    context '#metrics' do
      let(:hits_metric) { { 'id' => 1, 'system_name' => 'hits' } }
      let(:metrics) do
        [
          { 'id' => 10, 'system_name' => 'metric_10' },
          hits_metric,
          { 'id' => 20, 'system_name' => 'metric_20' }
        ]
      end
      let(:methods) do
        [
          { 'id' => 101, 'system_name' => 'method_101' },
          { 'id' => 201, 'system_name' => 'method_201' }
        ]
      end
      subject { backend.metrics }
      before :each do
        expect(remote).to receive(:list_backend_metrics).with(backend_id).and_return(metrics + methods)
        expect(remote).to receive(:list_backend_methods).with(backend_id, 1).and_return(methods)
      end

      it 'returns only metrics' do
        expect(subject.map(&:attrs)).to eq(metrics)
      end
    end

    context '#hits' do
      subject { backend.hits }
      context 'not found' do
        before :each do
          expect(remote).to receive(:list_backend_metrics).with(backend_id).and_return([])
        end

        it 'returns nil' do
          is_expected.to be_nil
        end
      end

      context 'found' do
        let(:hits_metric) { { 'id' => 1, 'system_name' => 'hits' } }
        let(:metrics) do
          [
            { 'id' => 10, 'system_name' => 'metric_10' },
            hits_metric,
            { 'id' => 20, 'system_name' => 'metric_20' }
          ]
        end
        before :each do
          expect(remote).to receive(:list_backend_metrics).with(backend_id).and_return(metrics)
        end

        it 'returns backendmetric' do
          expect(subject.id).to eq 1
          expect(subject.system_name).to eq 'hits'
        end
      end
    end
    context '#methods' do
      let(:hits_id) { 1 }
      let(:hits) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'hits') }
      subject { backend.methods hits }

      before :each do
        allow(hits).to receive(:id).and_return(hits_id)
      end

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:list_backend_methods).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:methods) do
          [
            { 'id' => 101, 'system_name' => 'method_101' },
            { 'id' => 201, 'system_name' => 'method_201' }
          ]
        end

        before :each do
          expect(remote).to receive(:list_backend_methods).and_return(methods)
        end

        it 'methods returned' do
          expect(subject.map(&:attrs)).to eq(methods)
        end
      end
    end
    context '#mapping_rules' do
      subject { backend.mapping_rules }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:list_backend_mapping_rules).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:mapping_rules) do
          [
            { 'id' => 101 },
            { 'id' => 201 }
          ]
        end

        before :each do
          expect(remote).to receive(:list_backend_mapping_rules).and_return(mapping_rules)
        end

        it 'mapping_rules returned' do
          expect(subject.map(&:attrs)).to eq(mapping_rules)
        end
      end
    end

    context '#update' do
      let(:new_attrs) { { 'name' => 'new name', 'unexpected_attrs': 3 } }
      subject { backend.update(new_attrs) }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:update_backend).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:expected_attrs) { { 'name' => 'new name' } }
        let(:remote_response) { expected_attrs.merge('id' => backend_id) }

        before :each do
          expect(remote).to receive(:update_backend).with(backend_id, expected_attrs).and_return(remote_response)
        end

        it 'new attrs returned' do
          is_expected.to eq(remote_response)
          expect(backend.attrs).to include(expected_attrs)
        end
      end
    end

    context '#delete' do
      subject { backend.delete }

      before :each do
        expect(remote).to receive(:delete_backend).with(backend_id).and_return(true)
      end

      it 'remote call done' do
        is_expected.to be_truthy
      end
    end

    context '#==' do
      let(:other_attrs) { { 'name' => 'other name' } }
      let(:other_backend) { described_class.new(id: other_backend_id, remote: other_remote, attrs: other_attrs) }
      let(:http_client) { double('http_client') }
      let(:other_http_client) { double('other_http_client') }
      let(:endpoint) { double('endpoint') }
      let(:other_endpoint) { double('other_endpoint') }

      before :each do
        allow(remote).to receive(:http_client).and_return(http_client)
        allow(other_remote).to receive(:http_client).and_return(other_http_client)
        allow(http_client).to receive(:endpoint).and_return(endpoint)
        allow(other_http_client).to receive(:endpoint).and_return(other_endpoint)
      end

      context 'when same remote and backend_id' do
        let(:other_backend_id) { backend_id }
        let(:other_remote) { remote }

        it 'are equal' do
          expect(backend == other_backend).to be_truthy
        end
      end

      context 'when diff remote' do
        let(:other_backend_id) { backend_id }
        let(:other_remote) { instance_double(ThreeScale::API::Client, 'other_remote') }

        it 'are not equal' do
          expect(backend == other_backend).to be_falsy
        end
      end

      context 'when diff backend_id' do
        let(:other_backend_id) { backend_id + 1 }
        let(:other_remote) { remote }

        it 'are not equal' do
          expect(backend == other_backend).to be_falsy
        end
      end
    end
  end
end
