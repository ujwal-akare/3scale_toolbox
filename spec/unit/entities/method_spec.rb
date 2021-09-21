RSpec.describe ThreeScaleToolbox::Entities::Method do
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:hits) { instance_double(ThreeScaleToolbox::Entities::Metric) }
  let(:service_id) { 1000 }
  let(:hits_id) { 1 }

  before :example do
    allow(hits).to receive(:id).and_return(hits_id)
    allow(service).to receive(:remote).and_return(remote)
    allow(service).to receive(:id).and_return(service_id)
    allow(service).to receive(:hits).and_return(hits)
  end

  context 'Method.create' do
    let(:method_attrs) { { system_name: 'some name' } }

    before :example do
      expect(remote).to receive(:create_method).with(service_id, hits_id, method_attrs)
                                               .and_return(remote_response)
    end

    context 'when remote return error' do
      let(:remote_response) { { 'errors' => true } }

      it 'throws error on remote error' do
        expect do
          described_class.create(service: service, attrs: method_attrs)
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Method has not been created/)
      end
    end

    context 'when remote call succeeds' do
      let(:method_id) { 1002 }

      let(:remote_response) { { 'id' => method_id } }

      it 'method instance is returned' do
        method_obj = described_class.create(service: service, attrs: method_attrs)
        expect(method_obj).not_to be_nil
        expect(method_obj.id).to eq(method_id)
      end
    end
  end

  context 'Method.find' do
    let(:service_id) { 1000 }
    let(:method_id) { 2000 }
    let(:method_system_name) { 'some_system_name' }
    let(:method_attrs) { { 'id' => method_id, 'system_name' => method_system_name } }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    context 'method is found by id' do
      let(:method_ref) { method_id }

      before :example do
        expect(remote).to receive(:show_method).with(service_id, hits_id, method_ref)
                                               .and_return(method_attrs)
      end

      it 'method instance is returned' do
        method_obj = described_class.find(service: service, ref: method_ref)
        expect(method_obj.id).to eq(method_id)
      end
    end

    context 'method is found by system_name' do
      let(:method_ref) { method_system_name }
      let(:my_method) { described_class.new(id: method_id, service: service, attrs: method_attrs) }
      let(:methods) { [my_method] }

      before :example do
        expect(remote).to receive(:show_method).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(service).to receive(:methods).and_return(methods)
      end

      it 'method instance is returned' do
        method_obj = described_class.find(service: service, ref: method_ref)
        expect(method_obj).not_to be_nil
        expect(method_obj.id).to eq(method_id)
      end
    end

    context 'method is not found' do
      let(:method_ref) { method_system_name }
      let(:methods) { [] }

      before :example do
        expect(remote).to receive(:show_method).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(service).to receive(:methods).and_return(methods)
      end

      it 'method instance is not returned' do
        expect(described_class.find(service: service, ref: method_ref)).to be_nil
      end
    end
  end

  context 'instance method' do
    let(:id) { 1774 }
    let(:service_id) { 4771 }
    let(:method_attrs) { nil }

    subject do
      described_class.new(id: id, service: service, attrs: method_attrs)
    end

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    context '#attrs' do
      context 'when initialized with empty attrs' do
        let(:method_attrs) { nil }
        let(:remote_attrs) { { 'id' => id, 'system_name' => 'some_system_name' } }

        before :example do
          expect(remote).to receive(:show_method).with(service_id, hits_id, id).and_return(remote_attrs)
        end

        it 'calling attrs fetch method attrs' do
          expect(subject.attrs).to eq(remote_attrs)
        end
      end

      context 'when initialized with not empty attrs' do
        let(:method_attrs) { { 'id' => id } }

        it 'calling attrs does not fetch metric attrs' do
          expect(subject.attrs).to eq(method_attrs)
        end
      end
    end

    context '#enable' do
      let(:metric_class) { class_double(ThreeScaleToolbox::Entities::Metric).as_stubbed_const }
      let(:metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }

      it 'metric instance is used' do
        expect(metric_class).to receive(:new).with(id: id, service: service).and_return(metric)
        expect(metric).to receive(:enable)
        subject.enable
      end
    end

    context '#disable' do
      let(:metric_class) { class_double(ThreeScaleToolbox::Entities::Metric).as_stubbed_const }
      let(:metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }

      it 'metric instance is used' do
        expect(metric_class).to receive(:new).with(id: id, service: service).and_return(metric)
        expect(metric).to receive(:disable)
        subject.disable
      end
    end

    context '#update' do
      let(:method_attrs) { { 'id' => id, 'system_name' => 'some name' } }
      let(:new_method_attrs) { { 'id' => id, 'someattr' => 2, 'system_name' => 'some name' } }
      let(:response_body) {}

      before :example do
        expect(remote).to receive(:update_method).with(service_id, hits_id, id, method_attrs)
                                                 .and_return(response_body)
      end

      context 'when method is updated' do
        let(:response_body) { new_method_attrs }

        it 'method new attrs are returned' do
          expect(subject.update(method_attrs)).to eq(new_method_attrs)
        end
      end

      context 'operation returns error' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'raises error' do
          expect { subject.update(method_attrs) }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                                 /Method has not been updated/)
        end
      end
    end

    context '#to_cr' do
      let(:method_attrs) do
        {
          'system_name' => 'method_1774', 'friendly_name' => 'some_friendly_name',
          'description' => 'some descr'
        }
      end

      subject { described_class.new(id: id, service: service, attrs: method_attrs).to_cr }

      it 'expected friendlyName' do
        expect(subject).to include('friendlyName' => 'some_friendly_name')
      end

      it 'expected description' do
        expect(subject).to include('description' => 'some descr')
      end
    end

    context '#to_hash' do
      let(:friendly_name) { 'some_friendly_name' }
      let(:system_name) { 'some_system_name' }
      let(:attrs) do
        {
          'id' => id,
          'friendly_name' => friendly_name,
          'system_name' => system_name,
          'description' => 'some descr',
          'links' => [],
          'created_at' => 'now',
          'updated_at' => 'now'
        }
      end
      subject {  described_class.new(id: id, service: service, attrs: attrs).to_hash }

      it 'expected number of attrs' do
        # 3 valid from the source attrs
        expect(subject.length).to eq(3)
      end

      it 'expected friendly_name' do
        expect(subject).to include('friendly_name' => friendly_name)
      end

      it 'expected description' do
        expect(subject).to include('description' => 'some descr')
      end

      it 'expected system_name' do
        expect(subject).to include('system_name' => system_name)
      end
    end

    context '#enriched_key' do
      subject {  described_class.new(id: id, service: service, attrs: method_attrs).enriched_key }

      it { is_expected.to eq("product.#{service.id}.#{id}") }
    end
  end
end
