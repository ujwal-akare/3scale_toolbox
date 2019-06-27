RSpec.describe ThreeScaleToolbox::Entities::Application do
  let(:account_id) { 'accId' }
  let(:plan_id) { 'planId' }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }

  context '#Application.find' do
    let(:app_ref) { 'application_ref' }
    let(:application_id) { 1000 }
    let(:app_attrs) { { 'id' => application_id, 'name' => 'myApp' } }

    context 'remote returns error' do
      before :example do
        expect(remote).to receive(:find_application).and_return('errors' => 'some error')
      end

      it 'raises error' do
        expect do
          described_class.find(remote: remote, ref: app_ref)
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Application find error/)
      end
    end

    context 'app found by user key' do
      before :example do
        expect(remote).to receive(:find_application).with(user_key: app_ref, service_id: nil)
                                                    .and_return(app_attrs)
      end

      it 'instance returned' do
        app = described_class.find(remote: remote, ref: app_ref)
        expect(app).not_to be_nil
        expect(app.id).to eq(application_id)
      end
    end

    context 'app found by app id' do
      before :example do
        expect(remote).to receive(:find_application).with(user_key: app_ref, service_id: nil)
                                                    .and_raise(ThreeScale::API::HttpClient::NotFoundError)
        expect(remote).to receive(:find_application).with(application_id: app_ref, service_id: nil)
                                                    .and_return(app_attrs)
      end

      it 'instance returned' do
        app = described_class.find(remote: remote, ref: app_ref)
        expect(app).not_to be_nil
        expect(app.id).to eq(application_id)
      end
    end

    context 'app found by id' do
      before :example do
        expect(remote).to receive(:find_application).with(user_key: app_ref, service_id: nil)
                                                    .and_raise(ThreeScale::API::HttpClient::NotFoundError)
        expect(remote).to receive(:find_application).with(application_id: app_ref, service_id: nil)
                                                    .and_raise(ThreeScale::API::HttpClient::NotFoundError)
        expect(remote).to receive(:find_application).with(id: app_ref, service_id: nil)
                                                    .and_return(app_attrs)
      end

      it 'instance returned' do
        app = described_class.find(remote: remote, ref: app_ref)
        expect(app).not_to be_nil
        expect(app.id).to eq(application_id)
      end
    end

    context 'app found by id and service_id' do
      let(:service_id) { 100 }
      before :example do
        expect(remote).to receive(:find_application).with(user_key: app_ref,
                                                          service_id: service_id)
                                                    .and_return(app_attrs)
      end

      it 'instance returned' do
        app = described_class.find(remote: remote, service_id: service_id, ref: app_ref)
        expect(app).not_to be_nil
        expect(app.id).to eq(application_id)
      end
    end
  end

  context '#Application.create' do
    let(:app_attrs) { { 'name' => 'myApp' } }
    before :example do
      expect(remote).to receive(:create_application).with(
        account_id, app_attrs, plan_id: plan_id
      ).and_return(create_app_response)
    end

    context 'remote returns error' do
      let(:create_app_response) { { 'errors' => 'some error' } }

      it 'raises error' do
        expect do
          described_class.create(
            remote: remote,
            account_id: account_id,
            plan_id: plan_id,
            app_attrs: app_attrs
          )
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Application has not been created/)
      end
    end

    context 'remote returns attrs' do
      let(:create_app_response) { app_attrs.merge('id' => 'appId') }

      it 'application instance is returned' do
        app = described_class.create(remote: remote, account_id: account_id,
                                     plan_id: plan_id,
                                     app_attrs: app_attrs)
        expect(app).not_to be_nil
        expect(app.id).to eq('appId')
      end
    end
  end

  context 'instance method' do
    let(:id) { 1774 }
    let(:account_id) { 'accId' }
    let(:base_attrs) do
      { 'id' => id, 'name' => 'somename', 'state' => 'live', 'account_id' => account_id }
    end
    let(:app_attrs) { base_attrs }
    let(:remote_app_attrs) { { 'id' => id, 'name' => 'somename' } }
    subject do
      described_class.new(id: id, remote: remote, attrs: app_attrs)
    end

    context '#attrs' do
      context 'when initialized with empty attrs' do
        let(:app_attrs) { nil }
        let(:remote_attrs) { { 'id' => id, 'system_name' => 'some_system_name' } }

        before :example do
          expect(remote).to receive(:show_application).with(id).and_return(remote_app_attrs)
        end

        it 'calling attrs fetch remote attrs' do
          expect(subject.attrs).to eq(remote_app_attrs)
        end
      end

      context 'when initialized with not empty attrs' do
        let(:app_attrs) { { 'id' => id, 'name' => 'somename' } }

        it 'calling attrs does not fetch metric attrs' do
          expect(subject.attrs).to eq(app_attrs)
        end
      end
    end

    context '#update' do
      let(:new_attrs) { { 'name' => 'new name' } }

      before :example do
        expect(remote).to receive(:update_application).with(account_id, id, new_attrs)
                                                      .and_return(response_body)
      end

      context 'update returns error' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'raises error' do
          expect { subject.update(new_attrs) }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                              /Application has not been updated/)
        end
      end

      context 'when application is updated' do
        let(:new_remote_attrs) { new_attrs.merge('id' => id) }
        let(:response_body) { new_remote_attrs }

        it 'plan attrs are returned' do
          expect(subject.update(new_attrs)).to eq(new_remote_attrs)
          expect(subject.attrs).to eq(new_remote_attrs)
        end
      end
    end

    context '#resume' do
      context 'live app' do
        let(:app_attrs) { base_attrs.merge('state' => 'live') }

        it 'is not resumed' do
          expect(subject.resume).to eq(app_attrs)
        end
      end

      context 'suspended app' do
        let(:app_attrs) { base_attrs.merge('state' => 'suspended') }

        before :example do
          expect(remote).to receive(:resume_application).with(account_id, id)
                                                        .and_return(response_body)
        end

        context 'resume returns error' do
          let(:response_body) { { 'errors' => 'some error' } }

          it 'raises error' do
            expect { subject.resume }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                     /Application has not been resumed/)
          end
        end

        context 'resume request return ok' do
          let(:new_remote_attrs) { { 'id' => id, 'state' => 'live' } }
          let(:response_body) { new_remote_attrs }

          it 'new attrs are returned' do
            expect(subject.resume).to eq(new_remote_attrs)
            expect(subject.attrs).to eq(new_remote_attrs)
          end
        end
      end
    end

    context '#suspend' do
      context 'suspended app' do
        let(:app_attrs) { base_attrs.merge('state' => 'suspended') }

        it 'is not suspended' do
          expect(subject.suspend).to eq(app_attrs)
        end
      end

      context 'resumed app' do
        let(:app_attrs) { base_attrs.merge('state' => 'live') }

        before :example do
          expect(remote).to receive(:suspend_application).with(account_id, id)
                                                         .and_return(response_body)
        end

        context 'resume returns error' do
          let(:response_body) { { 'errors' => 'some error' } }

          it 'raises error' do
            expect { subject.suspend }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                      /Application has not been suspended/)
          end
        end

        context 'suspend request returns ok' do
          let(:new_remote_attrs) { { 'id' => id, 'state' => 'suspended' } }
          let(:response_body) { new_remote_attrs }

          it 'new attrs are returned' do
            expect(subject.suspend).to eq(new_remote_attrs)
            expect(subject.attrs).to eq(new_remote_attrs)
          end
        end
      end
    end

    context '#delete' do
      it 'calls delete_application method' do
        expect(remote).to receive(:delete_application).with(account_id, id)
        subject.delete
      end
    end
  end
end
