RSpec.describe ThreeScaleToolbox::Entities::Limit do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:plan_id) { 1 }
  let(:metric_id) { 2 }

  before :each do
    allow(plan).to receive(:id).and_return(plan_id)
    allow(plan).to receive(:remote).and_return(remote)
  end

  context 'Limit.create' do
    let(:attrs) { { 'period' => 'eternity', 'value' => 0 } }
    subject { described_class.create(plan: plan, metric_id: metric_id, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_application_plan_limit).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:attrs) {  { 'period' => 'eternity' } }
      let(:limit_id) { 1 }
      let(:response) { { 'id' => limit_id, 'period' => 'eternity' } }

      before :each do
        expect(remote).to receive(:create_application_plan_limit).with(plan_id, metric_id, attrs).and_return(response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq limit_id
      end
    end
  end

  context 'instance method' do
    let(:limit_id) { 999 }
    let(:metric_id) { 888 }
    let(:attrs) do
      {
        'period' => 'eternity',
        'value' => 1,
      }
    end
    let(:limit) { described_class.new(id: limit_id, plan: plan, metric_id: metric_id, attrs: attrs) }

    context '#metric_id' do
      subject { limit.metric_id }

      it 'returns metric_id' do
        is_expected.to eq metric_id
      end
    end

    context '#period' do
      subject { limit.period }

      it 'returns period' do
        is_expected.to eq 'eternity'
      end
    end

    context '#value' do
      subject { limit.value }

      it 'returns value' do
        is_expected.to eq 1
      end
    end

    context '#update' do
      let(:new_value) { 2 }
      let(:new_attrs) { { 'value' => new_value, 'unexpected_attrs': 3 } }
      subject { limit.update(new_attrs) }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:update_application_plan_limit).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:remote_response) do
          {
            'id' => limit_id,
            'value' => new_value,
            'period' => 'eternity',
          }
        end

        before :each do
          expect(remote).to receive(:update_application_plan_limit).with(plan_id, metric_id, limit_id, new_attrs).and_return(remote_response)
        end

        it 'new attrs returned' do
          is_expected.to eq(remote_response)
          expect(limit.value).to eq(new_value)
          expect(limit.period).to eq('eternity')
        end
      end
    end

    context '#delete' do
      subject { limit.delete }

      before :each do
        expect(remote).to receive(:delete_application_plan_limit).with(plan_id, metric_id, limit_id).and_return(true)
      end

      it 'remote call done' do
        is_expected.to be_truthy
      end
    end
  end
end
