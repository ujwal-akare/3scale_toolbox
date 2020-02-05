RSpec.describe ThreeScaleToolbox::Entities::BackendUsage do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:product) { instance_double(ThreeScaleToolbox::Entities::Service, 'product') }
  let(:backend_id) { 200 }
  let(:product_id) { 100 }

  before :each do
    allow(product).to receive(:id).and_return(product_id)
    allow(product).to receive(:remote).and_return(remote)
  end

  context 'BackendUsage.create' do
    let(:path) { '/v1' }
    let(:attrs) do
      {
        'backend_api_id' => backend_id,
        'path' => path
      }
    end

    subject { described_class.create(product: product, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_backend_usage).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:attrs) do
        {
          'backend_api_id' => backend_id,
          'path' => path,
          'backend_id' => backend_id, # shold be filtered out
          'unexpected_attrs': 3 # shold be filtered out
        }
      end
      let(:expected_attrs) do
        {
          'backend_api_id' => backend_id,
          'path' => path
        }
      end
      let(:backend_usage_id) { 999 }
      let(:remote_response) do
        {
          'id' => backend_usage_id,
          'backend_id' => backend_id,
          'service_id' => product_id,
          'path' => path
        }
      end
      before :each do
        expect(remote).to receive(:create_backend_usage).with(product_id, expected_attrs).and_return(remote_response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq backend_usage_id
      end
    end
  end

  context 'BackendUsage.find_by_path' do
    let(:path) { '/v1' }
    subject { described_class.find_by_path(product: product, path: path) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:list_backend_usages).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when backend usage does not exist' do
      before :each do
        expect(remote).to receive(:list_backend_usages).with(product_id).and_return([])
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when backend usage is found by path' do
      let(:backend_usage_a) do
        {
          'id' => 1,
          'backend_id' => backend_id,
          'service_id' => product_id,
          'path' => path
        }
      end
      before :each do
        expect(remote).to receive(:list_backend_usages).with(product_id).and_return([backend_usage_a])
      end

      it 'instance is returned' do
        expect(subject.path).to eq path
      end
    end
  end

  context 'instance method' do
    let(:backend_usage_id) { 999 }
    let(:path) { '/v1' }
    let(:attrs) do
      {
        'id' => backend_usage_id,
        'backend_id' => backend_id,
        'path' => path
      }
    end
    let(:backend_usage) { described_class.new(id: backend_usage_id, product: product, attrs: attrs) }

    context '#attrs' do
      subject { backend_usage.attrs }

      context 'when no attrs available' do
        let(:attrs) { nil }
        let(:remote_response) { { 'id' => backend_usage_id, 'backend_id' => backend_id, 'path' => '/v1' }  }

        it 'remote fecth' do
          expect(remote).to receive(:backend_usage).with(product_id, backend_usage_id).and_return(remote_response)
          is_expected.to eq(remote_response)
        end
      end

      it 'attrs are available' do
        is_expected.to eq(attrs)
      end
    end

    context '#path' do
      subject { backend_usage.path }

      it 'returns path' do
        is_expected.to eq path
      end
    end

    context '#backend_id' do
      subject { backend_usage.backend_id}

      it 'returns backend_id' do
        is_expected.to eq backend_id
      end
    end

    context '#update' do
      let(:new_path) { '/new_path' }
      let(:new_attrs) do
        {
          'path' => new_path,
          'backend_id' => 1923,  # shold be filtered out
          'backend_api_id' => 1923, # shold be filtered out
          'unexpected_attrs': 3 # shold be filtered out
        }
      end
      subject { backend_usage.update(new_attrs) }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:update_backend_usage).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:expected_attrs) { { 'path' => new_path } }
        let(:remote_response) do
          {
            'id' => backend_usage_id,
            'backend_id' => backend_id,
            'service_id' => product_id,
            'path' => new_path
          }
        end

        before :each do
          expect(remote).to receive(:update_backend_usage).with(product_id, backend_usage_id, expected_attrs).and_return(remote_response)
        end

        it 'new attrs returned' do
          is_expected.to eq(remote_response)
          expect(backend_usage.attrs).to include(expected_attrs)
        end

        context 'but service_id does not match' do
          let(:remote_response) do
            {
              'id' => backend_usage_id,
              'backend_id' => backend_id,
              'service_id' => product_id + 1,
              'path' => new_path
            }
          end
          it 'error is raised' do
            expect { subject }.to raise_error(ThreeScaleToolbox::Error)
          end
        end
      end
    end

    context '#delete' do
      subject { backend_usage.delete }

      before :each do
        expect(remote).to receive(:delete_backend_usage).with(product_id, backend_usage_id).and_return(true)
      end

      it 'remote call done' do
        is_expected.to be_truthy
      end
    end
  end
end
