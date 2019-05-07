require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Entities::ApplicationPlan do
  let(:remote) { double('remote') }
  let(:service) { double('service') }

  before :example do
    allow(service).to receive(:remote).and_return(remote)
  end

  context 'ApplicationPlan.create' do
    let(:service_id) { 1000 }
    let(:plan_attrs) { { system_name: 'some name' } }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    it 'throws error on remote error' do
      expect(remote).to receive(:create_application_plan).with(service_id, plan_attrs)
                                                         .and_return('errors' => true)
      expect do
        described_class.create(service: service, plan_attrs: plan_attrs)
      end.to raise_error(ThreeScaleToolbox::Error, /Application plan has not been saved/)
    end

    it 'plan instance is returned' do
      expect(remote).to receive(:create_application_plan).with(service_id, plan_attrs)
                                                         .and_return('id' => 'some_id')
      plan_obj = described_class.create(service: service, plan_attrs: plan_attrs)
      expect(plan_obj.id).to eq('some_id')
      expect(plan_obj.remote).to be(remote)
    end
  end

  context 'instance method' do
    let(:id) { 1774 }
    subject { described_class.new(id: id, service: service) }

    context '#limits' do
      let(:limits) { double('limits') }
      it 'calls list_application_plan_limits method' do
        expect(remote).to receive(:list_application_plan_limits).with(id).and_return(limits)
        expect(subject.limits).to eq(limits)
      end
    end

    context '#create_limit' do
      let(:metric_id) { 4 }
      let(:limit_attrs) { { 'period' => 'year', 'value' => 10_000 } }
      let(:limit) { double('limit') }

      it 'calls create_application_plan_limit method' do
        expect(remote).to receive(:create_application_plan_limit).with(id, metric_id, limit_attrs)
                                                                 .and_return(limit)
        expect(subject.create_limit(metric_id, limit_attrs)).to eq(limit)
      end
    end
  end
end
