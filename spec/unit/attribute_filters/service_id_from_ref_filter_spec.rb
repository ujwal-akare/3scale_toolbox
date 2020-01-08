require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::AttributeFilters::ServiceIDFilterFromServiceRef do
  let(:service_id_key) { "service_id" }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }

  subject { described_class }
  it 'can be initialized' do
    expect { subject.new(remote, "ref", service_id_key) }.not_to raise_error
  end

  it 'implements AttributeFilter interface' do
    expect(subject.new(remote, "ref", service_id_key)).to respond_to(:filter)
  end

  context '#filter' do
    let(:ref) { 1 }
    let(:svc_1_attrs) { { "a" => 1, "b" => 2, "c" => 3 } }
    let(:svc_2_attrs) { { "a" => 4, "b" => 5, "c" => 6 } }
    let(:svc_3_attrs) { { "a" => 7, "b" => 8, "c" => 9 } }
    let(:elem_1) { { service_id_key => 1}.merge(svc_1_attrs) }
    let(:elem_2) { { service_id_key => 2}.merge(svc_2_attrs) }
    let(:elem_3) { { service_id_key => 3}.merge(svc_3_attrs) }
    let(:elems) { [elem_1, elem_2, elem_3] }

    context 'does not return any element when the filter key does not exist' do
      before :example do
        svc = ThreeScaleToolbox::Entities::Service.new(id: ref, remote: remote, attrs: svc_1_attrs)
        service_class = class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const
        expect(service_class).to receive(:find).with(remote: remote, ref: ref).and_return(svc)
      end

      it do
        attr_filter = subject.new(remote, ref, "nonexistent_service_id_key")
        res = attr_filter.filter(elems)
        expect(res).to be_empty
      end
    end

    context 'returns elements matching the service key ID and reference when the service exists' do
      before :example do
        svc = ThreeScaleToolbox::Entities::Service.new(id: ref, remote: remote, attrs: svc_1_attrs)
        service_class = class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const
        expect(service_class).to receive(:find).with(remote: remote, ref: ref).and_return(svc)
      end

      it do
        attr_filter = subject.new(remote, ref, service_id_key)
        res = attr_filter.filter(elems)
        expect(res).to eq([elem_1])
      end
    end

    context 'does not return an element matching the service key ID if the service does not exist' do
      before :example do
        service_class = class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const
        expect(service_class).to receive(:find).with(remote: remote, ref: ref).and_return(nil)
      end

      it do
        attr_filter = subject.new(remote, ref, service_id_key)
        res = attr_filter.filter(elems)
        expect(res).to be_empty
      end
    end

    context 'does not return any element when the reference does not match any existing ID from the list' do
      let(:ref) { 4 }
      let(:svc_4_attrs) { { "a" => 10, "b" => 11, "c" => 12 } }

      before :example do
        svc = ThreeScaleToolbox::Entities::Service.new(id: ref, remote: remote, attrs: svc_4_attrs)
        service_class = class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const
        expect(service_class).to receive(:find).with(remote: remote, ref: ref).and_return(svc)
      end

      it do
        attr_filter = subject.new(remote, ref, service_id_key)
        res = attr_filter.filter(elems)
        expect(res).to be_empty
      end
    end
  end
end