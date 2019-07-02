RSpec.describe ThreeScaleToolbox::Entities::ApplicationPlan do
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }

  before :example do
    allow(service).to receive(:remote).and_return(remote)
  end

  context 'ApplicationPlan.create' do
    let(:service_id) { 1000 }
    let(:plan_id) { 1001 }
    let(:plan_attrs) { { system_name: 'some name' } }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    it 'throws error on remote error' do
      expect(remote).to receive(:create_application_plan).with(service_id, plan_attrs)
                                                         .and_return('errors' => true)
      expect do
        described_class.create(service: service, plan_attrs: plan_attrs)
      end.to raise_error(ThreeScaleToolbox::Error, /Application plan has not been created/)
    end

    it 'plan instance is returned' do
      expect(remote).to receive(:create_application_plan).with(service_id, plan_attrs)
                                                         .and_return('id' => plan_id)
      plan_obj = described_class.create(service: service, plan_attrs: plan_attrs)
      expect(plan_obj.id).to eq(plan_id)
      expect(plan_obj.remote).to be(remote)
    end

    context 'attrs include published state' do
      let(:plan_attrs) { { 'system_name' => 'some_name', 'state' => 'published' } }

      it 'plan attrs include state_event as publish' do
        expected_create_attrs = {
          'system_name' => 'some_name',
          'state_event' => 'publish'
        }
        expect(remote).to receive(:create_application_plan).with(service_id, hash_including(expected_create_attrs))
                                                           .and_return('id' => plan_id)
        plan_obj = described_class.create(service: service, plan_attrs: plan_attrs)
        expect(plan_obj.id).to eq(plan_id)
        expect(plan_obj.remote).to be(remote)
      end
    end

    context 'attrs include hidden state' do
      let(:plan_attrs) { { 'system_name' => 'some_name', 'state' => 'hidden' } }

      it 'plan attrs include state_event as hide' do
        expected_create_attrs = { 'system_name' => 'some_name' }
        expect(remote).to receive(:create_application_plan).with(service_id, hash_including(expected_create_attrs))
                                                           .and_return('id' => plan_id)
        plan_obj = described_class.create(service: service, plan_attrs: plan_attrs)
        expect(plan_obj.id).to eq(plan_id)
        expect(plan_obj.remote).to be(remote)
      end
    end
  end

  context 'ApplicationPlan.find' do
    let(:service_id) { 1000 }
    let(:plan_id) { 2000 }
    let(:plan_system_name) { 'some_system_name' }
    let(:plan_attrs) { { 'id' => plan_id, 'system_name' => plan_system_name } }

    before :example do
      allow(service).to receive(:id).and_return(service_id)
    end

    context 'plan is found by id' do
      let(:plan_ref) { plan_id }

      before :example do
        expect(remote).to receive(:show_application_plan).with(service_id, plan_ref)
                                                         .and_return(plan_attrs)
      end

      it 'plan instance is returned' do
        plan_obj = described_class.find(service: service, ref: plan_ref)
        expect(plan_obj.id).to eq(plan_id)
      end
    end

    context 'plan is found by system_name' do
      let(:plan_ref) { plan_system_name }
      let(:plans) { [plan_attrs] }

      before :example do
        expect(remote).to receive(:show_application_plan).and_raise(ThreeScale::API::HttpClient::NotFoundError)
        expect(service).to receive(:plans).and_return(plans)
      end

      it 'plan instance is returned' do
        plan_obj = described_class.find(service: service, ref: plan_ref)
        expect(plan_obj.id).to eq(plan_id)
      end
    end

    context 'plan is not found' do
      let(:plan_ref) { plan_system_name }
      let(:plans) { [] }

      before :example do
        expect(remote).to receive(:show_application_plan).and_raise(ThreeScale::API::HttpClient::NotFoundError)
        expect(service).to receive(:plans).and_return(plans)
      end

      it 'plan instance is not returned' do
        plan_obj = described_class.find(service: service, ref: plan_ref)
        expect(plan_obj).to be_nil
      end
    end
  end

  context 'instance method' do
    let(:id) { 1774 }
    let(:service_id) { 4771 }
    let(:initial_state) { 'published' }
    let(:initial_plan_attrs) do
      {
        'id' => id, 'state' => initial_state,
        'system_name' => 'system_name01', 'name' => 'some name'
      }
    end

    subject { described_class.new(id: id, service: service, attrs: initial_plan_attrs) }

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

    context '#update' do
      context 'empty params' do
        it 'plan is not updated' do
          expect(subject.update({})).to eq(initial_plan_attrs)
        end
      end

      context 'when initially published and new state is published' do
        it 'plan is not updated' do
          expect(subject.update('state' => 'published')).to eq(initial_plan_attrs)
        end
      end

      context 'when initially hidden and new state is hidden' do
        let(:initial_state) { 'hidden' }

        it 'plan is not updated' do
          expect(subject.update('state' => 'hidden')).to eq(initial_plan_attrs)
        end
      end

      context 'not empty params' do
        let(:plan_attrs) { { 'id' => id, 'system_name' => 'system_name01', 'name' => 'some name' } }
        let(:new_plan_attrs) do
          { 'id' => id, 'someattr' => 2, 'system_name' => 'system_name01', 'name' => 'some name' }
        end
        let(:update_plan_attrs) { { 'name' => 'some name' } }
        let(:response_body) { new_plan_attrs }

        before :example do
          expect(remote).to receive(:update_application_plan).with(service_id, id,
                                                                   update_plan_attrs)
                                                             .and_return(response_body)
        end

        it 'plan attrs are returned' do
          expect(subject.update(plan_attrs)).to eq(new_plan_attrs)
        end

        context 'attrs include published state' do
          let(:initial_state) { 'hidden' }
          let(:plan_attrs) { { 'state' => 'published' } }
          let(:update_plan_attrs) { { 'state_event' => 'publish' } }

          it 'plan attrs include state_event as publish' do
            expect(subject.update(plan_attrs)).to eq(new_plan_attrs)
          end
        end

        context 'attrs include hidden state' do
          let(:plan_attrs) { { 'state' => 'hidden' } }
          let(:update_plan_attrs) { { 'state_event' => 'hide' } }

          it 'plan attrs include state_event as hide' do
            expect(subject.update(plan_attrs)).to eq(new_plan_attrs)
          end
        end
      end

      context 'operation returns error' do
        let(:update_plan_attrs) { { 'name' => 'some name' } }
        let(:plan_attrs) { { 'id' => id, 'system_name' => 'system_name01', 'name' => 'some name' } }
        let(:response_body) { { 'errors' => 'some error' } }

        before :example do
          expect(remote).to receive(:update_application_plan).with(service_id, id,
                                                                   update_plan_attrs)
                                                             .and_return(response_body)
        end

        it 'raises error' do
          expect { subject.update(plan_attrs) }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                               /Application plan has not been updated/)
        end
      end
    end

    context '#applications' do
      context 'list_applications returns error' do
        let(:request_error) { { 'errors' => 'some error' } }

        before :example do
          expect(remote).to receive(:list_applications).with(service_id: service_id, plan_id: id)
                                                       .and_return(request_error)
        end

        it 'error is raised' do
          expect { subject.applications }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                         /Plan applications not read/)
        end
      end

      context 'list_applications returns applications' do
        let(:app01_attrs) { { 'id' => 1, 'name' => 'app01' } }
        let(:app02_attrs) { { 'id' => 2, 'name' => 'app02' } }
        let(:app03_attrs) { { 'id' => 3, 'name' => 'app03' } }
        let(:applications) { [app01_attrs, app02_attrs, app03_attrs] }

        before :example do
          expect(remote).to receive(:list_applications).with(service_id: service_id, plan_id: id)
                                                       .and_return(applications)
        end

        it 'app01 is returned' do
          apps = subject.applications
          expect(apps.map(&:id)).to include(1)
        end

        it 'app02 is returned' do
          apps = subject.applications
          expect(apps.map(&:id)).to include(2)
        end

        it 'app03 is returned' do
          apps = subject.applications
          expect(apps.map(&:id)).to include(3)
        end
      end
    end
  end
end
