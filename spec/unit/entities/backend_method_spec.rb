RSpec.describe ThreeScaleToolbox::Entities::BackendMethod do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'backend') }
  let(:backend_id) { 100 }
  let(:hits_id) { 666 }

  before :each do
    allow(backend).to receive(:id).and_return(backend_id)
    allow(backend).to receive(:remote).and_return(remote)
  end

  context 'BackendMethod.create' do
    let(:attrs) { { 'friendly_name' => 'some name' } }
    subject { described_class.create(backend: backend, parent_id: hits_id, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_backend_method).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:attrs) { { 'friendly_name' => 'some name', 'unexpected_param' => 3 } }
      let(:expected_attrs) { { 'friendly_name' => 'some name' } }
      let(:metric_id) { 1 }
      let(:response) { { 'id' => metric_id, 'friendly_name' => 'some name' } }
      before :each do
        expect(remote).to receive(:create_backend_method).with(backend_id, hits_id, expected_attrs).and_return(response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq metric_id
      end
    end
  end

  context 'BackendMethod.find' do
    let(:ref) { 1234 }
    subject { described_class.find(backend: backend, parent_id: hits_id, ref: ref) }

    context 'when backendmethod does not exist' do
      before :each do
        expect(remote).to receive(:backend_method).with(backend_id, hits_id, ref).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(backend).to receive(:methods).and_return([])
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when backendmethod is found by id' do
      let(:metric_attrs) { { 'id' => ref, 'system_name' => "my_name.#{backend_id}" } }
      before :each do
        expect(remote).to receive(:backend_method).with(backend_id, hits_id, ref).and_return(metric_attrs)
      end

      it 'instance is returned' do
        expect(subject.id).to eq ref
      end
    end

    context 'when backendmethod is found by system_name' do
      let(:ref) { 'some_system_name' }
      let(:metric_attrs) { { 'system_name' => "#{ref}.#{backend_id}" } }
      let(:metric_id) { 1 }
      let(:backend_method) { described_class.new(id: metric_id, parent_id: hits_id, backend: backend, attrs: metric_attrs) }
      before :each do
        expect(backend).to receive(:methods).and_return([backend_method])
      end

      it 'instance is returned' do
        expect(subject.id).to eq metric_id
      end
    end
  end

  context 'BackendMethod.find_by_system_name' do
    let(:system_name) { 'some_system_name' }
    subject { described_class.find_by_system_name(backend: backend, parent_id: hits_id, system_name: system_name) }

    context 'when backend is not found' do
      before :each do
        expect(backend).to receive(:methods).with(hits_id).and_return([])
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when backendmethod is found' do
      let(:metric_attrs) { { 'system_name' => "#{system_name}.#{backend_id}" } }
      let(:metric_id) { 1 }
      let(:backend_method) { described_class.new(id: metric_id, parent_id: hits_id, backend: backend, attrs: metric_attrs) }
      before :each do
        expect(backend).to receive(:methods).and_return([backend_method])
      end

      it 'instance is returned' do
        expect(subject.id).to eq metric_id
      end
    end
  end

  context 'instance method' do
    let(:backend_method_id) { 999 }
    let(:system_name) { 'some_system_name' }
    let(:friendly_name) { 'some_friendly_name' }
    let(:attrs) do
      {
        'id' => backend_method_id,
        'friendly_name' => friendly_name,
        'system_name' => "#{system_name}.#{backend_id}"
      }
    end
    let(:backend_method) { described_class.new(id: backend_method_id, parent_id: hits_id, backend: backend, attrs: attrs) }

    context '#attrs' do
      subject { backend_method.attrs }

      context 'when no attrs available' do
        let(:attrs) { nil }
        let(:remote_reponse) { { 'id' => backend_method_id, 'system_name' => "#{system_name}.#{backend_id}" }  }
        before :each do
          expect(remote).to receive(:backend_method).with(backend_id, hits_id, backend_method_id).and_return(remote_reponse)
        end

        it 'system_name is processed' do
          expect(subject.fetch('system_name')).to eq(system_name)
        end

        it 'id is available' do
          expect(subject.fetch('id')).to eq(backend_method_id)
        end
      end

      context 'when attrs are available' do
        it 'system_name is processed' do
          expect(subject.fetch('system_name')).to eq(system_name)
        end

        it 'id is available' do
          expect(subject.fetch('id')).to eq(backend_method_id)
        end
      end
    end

    context '#system_name' do
      subject { backend_method.system_name }

      it 'returns system_name' do
        is_expected.to eq system_name
      end
    end

    context '#friendly_name' do
      subject { backend_method.friendly_name }

      it 'returns friendly_name' do
        is_expected.to eq friendly_name
      end
    end

    context '#update' do
      let(:new_friendly_name) { 'new_name' }
      let(:new_attrs) { { 'friendly_name' => new_friendly_name, 'unexpected_attrs': 3 } }
      subject { backend_method.update(new_attrs) }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:update_backend_method).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:expected_attrs) { { 'friendly_name' => new_friendly_name } }
        let(:remote_response) do
          {
            'id' => backend_method_id,
            'friendly_name' => new_friendly_name,
            'system_name' => "#{system_name}.#{backend_id}"
          }
        end

        before :each do
          expect(remote).to receive(:update_backend_method).with(backend_id, hits_id, backend_method_id, expected_attrs).and_return(remote_response)
        end

        it 'system_name processed' do
          is_expected.to include('system_name' => system_name)
          expect(backend_method.attrs).to include('system_name' => system_name)
        end

        it 'friendly_name updated' do
          is_expected.to include('friendly_name' => new_friendly_name)
          expect(backend_method.attrs).to include('friendly_name' => new_friendly_name)
        end
      end
    end

    context '#delete' do
      subject { backend_method.delete }

      before :each do
        expect(remote).to receive(:delete_backend_method).with(backend_id, hits_id, backend_method_id).and_return(true)
      end

      it 'remote call done' do
        is_expected.to be_truthy
      end
    end
  end
end
