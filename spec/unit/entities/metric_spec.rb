RSpec.describe ThreeScaleToolbox::Entities::Metric do
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }

  before :example do
    allow(service).to receive(:remote).and_return(remote)
  end

  context 'Metric.create' do
    let(:service_id) { 1000 }
    let(:metric_attrs) { { system_name: 'some name' } }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    it 'throws error on remote error' do
      expect(remote).to receive(:create_metric).with(service_id, metric_attrs)
                                               .and_return('errors' => true)
      expect do
        described_class.create(service: service, attrs: metric_attrs)
      end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Metric has not been created/)
    end

    it 'metric instance is returned' do
      expect(remote).to receive(:create_metric).with(service_id, metric_attrs)
                                               .and_return('id' => 1000)
      metric_obj = described_class.create(service: service, attrs: metric_attrs)
      expect(metric_obj.id).to eq(1000)
    end
  end

  context 'Metric.find' do
    let(:service_id) { 1000 }
    let(:metric_id) { 2000 }
    let(:metric_system_name) { 'some_system_name' }
    let(:metric_attrs) { { 'id' => metric_id, 'system_name' => metric_system_name } }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    context 'metric is found by id' do
      let(:metric_ref) { metric_id }

      before :example do
        expect(remote).to receive(:show_metric).with(service_id, metric_ref)
                                               .and_return(metric_attrs)
      end

      it 'metric instance is returned' do
        metric_obj = described_class.find(service: service, ref: metric_ref)
        expect(metric_obj.id).to eq(metric_id)
      end
    end

    context 'metric is found by system_name' do
      let(:metric_ref) { metric_system_name }
      let(:my_metric) { described_class.new(id: metric_id, service: service, attrs: metric_attrs) }
      let(:metrics) { [my_metric] }

      before :example do
        expect(remote).to receive(:show_metric).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(service).to receive(:metrics).and_return(metrics)
      end

      it 'metric instance is returned' do
        metric_obj = described_class.find(service: service, ref: metric_ref)
        expect(metric_obj.id).to eq(metric_id)
      end
    end

    context 'metric is not found' do
      let(:metric_ref) { metric_system_name }
      let(:metrics) { [] }

      before :example do
        expect(remote).to receive(:show_metric).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(service).to receive(:metrics).and_return(metrics)
      end

      it 'metric instance is not returned' do
        expect(described_class.find(service: service, ref: metric_ref)).to be_nil
      end
    end
  end

  context 'instance method' do
    let(:id) { 1774 }
    let(:service_id) { 4771 }
    let(:metric_attrs) { nil }
    subject { described_class.new(id: id, service: service, attrs: metric_attrs) }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    context '#attrs' do
      context 'when initialized with empty attrs' do
        let(:remote_attrs) { { 'id' => id, 'system_name' => 'some_system_name' } }

        before :example do
          expect(remote).to receive(:show_metric).with(service_id, id).and_return(remote_attrs)
        end

        it 'calling attrs fetch metric attrs' do
          expect(subject.attrs).to eq(remote_attrs)
        end
      end

      context 'when initialized with not empty attrs' do
        let(:metric_attrs) { { 'id' => id } }

        it 'calling attrs does not fetch metric attrs' do
          expect(subject.attrs).to eq(metric_attrs)
        end
      end
    end

    context '#enable' do
      let(:plan_1) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
      let(:plan_2) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
      let(:plan_3) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
      let(:plans) { [ plan_1, plan_2, plan_3 ] }
      let(:limit_0_disabled) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_1) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_2_disabled) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_3) { instance_double(ThreeScaleToolbox::Entities::Limit) }

      before :example do
        expect(service).to receive(:plans).and_return(plans)
        expect(plan_1).to receive(:metric_limits).with(id).and_return([limit_0_disabled])
        expect(plan_2).to receive(:metric_limits).with(id).and_return([limit_1])
        expect(plan_3).to receive(:metric_limits).with(id).and_return([limit_2_disabled, limit_3])
        allow(limit_0_disabled).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 0, 'links' => [] })
        allow(limit_1).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 100, 'links' => [] })
        allow(limit_2_disabled).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 0, 'links' => [] })
        allow(limit_3).to receive(:attrs).and_return({ 'period' => 'year', 'value' => 0, 'links' => [] })
      end

      it 'eternity zero limits deleted' do
        expect(limit_0_disabled).to receive(:delete)
        expect(limit_2_disabled).to receive(:delete)

        subject.enable
      end
    end

    context '#disable' do
      let(:zero_eternity_limit_attrs) { { 'period' => 'eternity', 'value' => 0 } }
      let(:plan_0) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
      let(:plan_1) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
      let(:plan_2) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
      let(:plans) { [ plan_0, plan_1, plan_2 ] }
      let(:limit_0) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_1) { instance_double(ThreeScaleToolbox::Entities::Limit) }
      let(:limit_2) { instance_double(ThreeScaleToolbox::Entities::Limit) }

      before :example do
        expect(service).to receive(:plans).and_return(plans)
        expect(plan_0).to receive(:metric_limits).with(id).and_return([limit_0])
        expect(plan_1).to receive(:metric_limits).with(id).and_return([limit_1])
        expect(plan_2).to receive(:metric_limits).with(id).and_return([limit_2])
      end

      context 'when eternity non zero limits exist' do
        before :example do
          allow(limit_0).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 1000 })
          allow(limit_0).to receive(:period).and_return('eternity')
          allow(limit_0).to receive(:value).and_return(1000)
          allow(limit_1).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 2000 })
          allow(limit_1).to receive(:period).and_return('eternity')
          allow(limit_1).to receive(:value).and_return(2000)
          allow(limit_2).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 1000 })
          allow(limit_2).to receive(:period).and_return('eternity')
          allow(limit_2).to receive(:value).and_return(1000)
        end

        it 'eternity non zero limits updated' do
          expect(limit_0).to receive(:update).with(zero_eternity_limit_attrs)
          expect(limit_1).to receive(:update).with(zero_eternity_limit_attrs)
          expect(limit_2).to receive(:update).with(zero_eternity_limit_attrs)
          subject.disable
        end
      end

      context 'when no eternity limits exist' do
        before :example do
          allow(limit_0).to receive(:attrs).and_return({ 'period' => 'year', 'value' => 1000 })
          allow(limit_0).to receive(:period).and_return('year')
          allow(limit_0).to receive(:value).and_return(1000)
          allow(limit_1).to receive(:attrs).and_return({ 'period' => 'month', 'value' => 2000 })
          allow(limit_1).to receive(:period).and_return('month')
          allow(limit_1).to receive(:value).and_return(2000)
          allow(limit_2).to receive(:attrs).and_return({ 'period' => 'day', 'value' => 1000 })
          allow(limit_2).to receive(:period).and_return('day')
          allow(limit_2).to receive(:value).and_return(1000)
        end

        it 'eternity zero limits created' do
          expect(plan_0).to receive(:create_limit).with(id, zero_eternity_limit_attrs)
          expect(plan_1).to receive(:create_limit).with(id, zero_eternity_limit_attrs)
          expect(plan_2).to receive(:create_limit).with(id, zero_eternity_limit_attrs)
          subject.disable
        end
      end

      context 'when eternity zero limit exist' do
        before :example do
          allow(limit_0).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 0 })
          allow(limit_0).to receive(:period).and_return('eternity')
          allow(limit_0).to receive(:value).and_return(0)
          allow(limit_1).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 2000 })
          allow(limit_1).to receive(:period).and_return('eternity')
          allow(limit_1).to receive(:value).and_return(0)
          allow(limit_2).to receive(:attrs).and_return({ 'period' => 'eternity', 'value' => 1000 })
          allow(limit_2).to receive(:period).and_return('eternity')
          allow(limit_2).to receive(:value).and_return(0)
        end

        it 'noop' do
          subject.disable
        end
      end
    end

    context '#update' do
      let(:metric_attrs) { { 'id' => id, 'system_name' => 'some name' } }
      let(:new_metric_attrs) { { 'id' => id, 'someattr' => 2, 'system_name' => 'some name' } }
      let(:response_body) {}

      before :example do
        expect(remote).to receive(:update_metric).with(service_id, id, metric_attrs)
                                                 .and_return(response_body)
      end

      context 'when metric is updated' do
        let(:response_body) { new_metric_attrs }

        it 'metric new attrs are returned' do
          expect(subject.update(metric_attrs)).to eq(new_metric_attrs)
        end
      end

      context 'operation returns error' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'raises error' do
          expect { subject.update(metric_attrs) }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                                 /Metric has not been updated/)
        end
      end
    end
  end
end
