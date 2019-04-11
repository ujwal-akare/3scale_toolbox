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
    let(:service_id) { 4771 }
    subject { described_class.new(id: id, service: service) }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

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
      let(:limit) { limit_attrs.merge('id' => 1) }

      it 'calls create_application_plan_limit method' do
        expect(remote).to receive(:create_application_plan_limit).with(id, metric_id, limit_attrs)
                                                                 .and_return(limit)
        expect(subject.create_limit(metric_id, limit_attrs)).to eq(limit)
      end
    end

    context '#make_default' do
      let(:plan_attrs) { { 'id' => id, system_name: 'some name', 'default' => true } }
      let(:response_body) { plan_attrs }

      before :example do
        expect(remote).to receive(:application_plan_as_default).with(service_id, id)
                                                               .and_return(response_body)
      end

      it 'plan_attrs are returned' do
        expect(subject.make_default).to eq(plan_attrs)
      end

      context 'operation returns error' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'raises error' do
          expect { subject.make_default }.to raise_error(ThreeScaleToolbox::Error,
                                                         /has not been set to default/)
        end
      end
    end

    context '#enable' do
      let(:limit_0_disabled) { { 'id' => 0, 'metric_id' => 1, 'period' => 'eternity', 'value' => 0 } }
      let(:limit_1_enabled) { { 'id' => 1, 'metric_id' => 2, 'period' => 'eternity', 'value' => 100 } }
      let(:limit_2_disabled) { { 'id' => 2, 'metric_id' => 3, 'period' => 'eternity', 'value' => 0 } }
      let(:limit_3_enabled) { { 'id' => 3, 'metric_id' => 4, 'period' => 'year', 'value' => 0 } }
      let(:limits) do
        [limit_0_disabled, limit_1_enabled, limit_2_disabled, limit_3_enabled]
      end

      before :example do
        expect(remote).to receive(:list_application_plan_limits).with(id).and_return(limits)
      end

      it 'eternity zero limits deleted' do
        # limit_0_disabled
        expect(remote).to receive(:delete_application_plan_limit).with(id, 1, 0)
        # limit_2_disabled
        expect(remote).to receive(:delete_application_plan_limit).with(id, 3, 2)

        subject.enable
      end
    end

    context '#disable' do
      let(:zero_eternity_limit_attrs) { { 'period' => 'eternity', 'value' => 0 } }

      before :example do
        expect(remote).to receive(:list_application_plan_limits).with(id).and_return(limits)
        expect(service).to receive(:metrics).and_return(metrics)
      end

      context 'when eternity non zero limits exist' do
        let(:metric_0) { { 'id' => 0 } }
        let(:metric_1) { { 'id' => 1 } }
        let(:limit_0) do
          {
            'id' => 0, 'metric_id' => metric_0.fetch('id'),
            'period' => 'eternity', 'value' => 10_000
          }
        end
        let(:limit_1) do
          {
            'id' => 1, 'metric_id' => metric_1.fetch('id'),
            'period' => 'eternity', 'value' => 10_000
          }
        end
        let(:limits) { [limit_0, limit_1] }
        let(:metrics) { [metric_0, metric_1] }

        it 'limits updated to zero' do
          expect(remote).to receive(:update_application_plan_limit).with(id, metric_0.fetch('id'), limit_0.fetch('id'), zero_eternity_limit_attrs)
                                                                   .and_return('id' => limit_0.fetch('id'))
          expect(remote).to receive(:update_application_plan_limit).with(id, metric_1.fetch('id'), limit_1.fetch('id'), zero_eternity_limit_attrs)
                                                                   .and_return('id' => limit_1.fetch('id'))
          subject.disable
        end
      end

      context 'when metrics with no eternity period limit exist' do
        let(:metric_0) { { 'id' => 0 } }
        let(:metric_1) { { 'id' => 1 } }
        let(:limit_0) do
          {
            'id' => 0, 'metric_id' => metric_0.fetch('id'),
            'period' => 'year', 'value' => 10_000
          }
        end
        let(:limit_1) do
          {
            'id' => 1, 'metric_id' => metric_1.fetch('id'),
            'period' => 'month', 'value' => 10_000
          }
        end
        let(:limits) { [limit_0, limit_1] }
        let(:metrics) { [metric_0, metric_1] }

        it 'eternity zero limits created' do
          expect(remote).to receive(:create_application_plan_limit).with(id, metric_0.fetch('id'), zero_eternity_limit_attrs)
                                                                   .and_return('id' => 1000)
          expect(remote).to receive(:create_application_plan_limit).with(id, metric_1.fetch('id'), zero_eternity_limit_attrs)
                                                                   .and_return('id' => 1001)
          subject.disable
        end
      end

      context 'when metrics with eternity zero limit exist' do
        let(:metric_0) { { 'id' => 0 } }
        let(:metric_1) { { 'id' => 1 } }
        let(:limit_0) do
          {
            'id' => 0, 'metric_id' => metric_0.fetch('id'),
            'period' => 'eternity', 'value' => 0
          }
        end
        let(:limit_1) do
          {
            'id' => 1, 'metric_id' => metric_1.fetch('id'),
            'period' => 'eternity', 'value' => 0
          }
        end
        let(:limits) { [limit_0, limit_1] }
        let(:metrics) { [metric_0, metric_1] }
        it 'noop' do
          subject.disable
        end
      end
    end
  end
end
