RSpec.describe ThreeScaleToolbox::Commands::ApplicationCommand::Apply::ApplySubcommand do
  let(:app_ref) { 'someapp' }
  let(:arguments) { { remote: 'https://key@destination.example.com', application: app_ref } }
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service_id) { 100 }
  let(:account_id) { 200 }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:account_class) { class_double(ThreeScaleToolbox::Entities::Account).as_stubbed_const }
  let(:account) { instance_double(ThreeScaleToolbox::Entities::Account) }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:application_class) { class_double(ThreeScaleToolbox::Entities::Application).as_stubbed_const }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:application) { instance_double(ThreeScaleToolbox::Entities::Application) }
  subject { described_class.new(options, arguments, nil) }

  before :example do
    allow(service).to receive(:id).and_return(service_id)
    allow(account).to receive(:id).and_return(account_id)
  end

  context '#run' do
    context 'resume and suspend passed' do
      let(:options) { { resume: true, suspend: true } }
      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /--resume and --suspend are mutually exclusive/)
      end
    end

    context 'application found' do
      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
        expect(application_class).to receive(:find).with(remote: remote,
                                                         service_id: nil,
                                                         ref: app_ref)
                                                   .and_return(application)
        expect(application).to receive(:id).and_return(1)
      end

      context 'no app attrs' do
        let(:options) { {} }

        it 'application not updated' do
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end

      context 'resumed opt given' do
        let(:options) { { resume: true } }

        it 'application resumed' do
          expect(application).to receive(:resume)
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end

      context 'suspended opt given' do
        let(:options) { { suspend: true } }

        it 'application suspended' do
          expect(application).to receive(:suspend)
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end

      context 'name opt given' do
        let(:options) { { name: 'new name' } }

        it 'application updated with name' do
          expect(application).to receive(:update).with(hash_including('name' => 'new name'))
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end

        it 'application updated with description as name' do
          expect(application).to receive(:update).with(hash_including('description' => 'new name'))
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end

      context 'description opt given' do
        let(:options) { { description: 'new descr' } }

        it 'application updated with description' do
          expect(application).to receive(:update).with(hash_including('description' => 'new descr'))
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end

      context 'user_key opt given' do
        let(:options) { { 'user-key': 'userKey' } }

        it 'application updated with user key' do
          expect(application).to receive(:update).with(hash_including('user_key' => 'userKey'))
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end
    end

    context 'application not found' do
      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
        expect(application_class).to receive(:find).with(remote: remote, service_id: service_id,
                                                         ref: app_ref)
                                                   .and_return(nil)
      end

      context 'account opt not given' do
        let(:options) do
          {
            service: 'myservice',
            plan: 'myplan',
            name: 'myname'
          }
        end

        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /--account is required/)
        end
      end

      context 'service opt not given' do
        let(:service_id) { nil }
        let(:options) do
          {
            account: 'myaccount',
            plan: 'myplan',
            name: 'myname'
          }
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /--service is required/)
        end
      end

      context 'plan opt not given' do
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            name: 'myname'
          }
        end

        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /--plan is required/)
        end
      end

      context 'name opt not given' do
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            plan: 'myplan'
          }
        end

        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /--name is required/)
        end
      end

      context 'user-key opt given' do
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            plan: 'myplan',
            name: 'myname',
            'user-key': 'userKey'
          }
        end

        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /--user-key option forbidden/)
        end
      end

      context 'account not found' do
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            plan: 'myplan',
            name: 'myname'
          }
        end

        before :example do
          expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                                 .and_return(nil)
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /Account myaccount does not exist/)
        end
      end

      context 'service not found' do
        let(:service_id) { nil }
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            plan: 'myplan',
            name: 'myname'
          }
        end

        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(nil)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /Service myservice does not exist/)
        end
      end

      context 'plan not found' do
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            plan: 'myplan',
            name: 'myname'
          }
        end

        before :example do
          expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                                 .and_return(account)
          expect(account).to receive(:id).and_return(1)
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
          expect(plan_class).to receive(:find).with(service: service, ref: 'myplan')
                                              .and_return(nil)
        end

        it 'error raised' do
          expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                /Application plan myplan does not exist/)
        end
      end

      context 'all required params available' do
        let(:options) do
          {
            account: 'myaccount',
            service: 'myservice',
            plan: 'myplan',
            name: 'myname',
            description: 'mydescr',
            'application-key': 'appKey'
          }
        end

        before :example do
          expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                                 .and_return(account)
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
          expect(plan_class).to receive(:find).with(service: service, ref: 'myplan')
                                              .and_return(plan)
          expect(plan).to receive(:id).and_return('planId')
          expect(application).to receive(:id).and_return(1)
        end

        it 'user_key set to application param' do
          expect(application_class).to receive(:create)
            .with(
              remote: remote, account_id: account_id,
              plan_id: 'planId', app_attrs: hash_including('user_key' => app_ref)
            )
            .and_return(application)
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end

        it 'application_id set to application param' do
          expect(application_class).to receive(:create)
            .with(
              remote: remote, account_id: account_id,
              plan_id: 'planId', app_attrs: hash_including('application_id' => app_ref)
            )
            .and_return(application)
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end

        it 'description is included' do
          expect(application_class).to receive(:create)
            .with(
              remote: remote, account_id: account_id, plan_id: 'planId',
              app_attrs: hash_including('description' => 'mydescr')
            )
            .and_return(application)
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end

        it 'application key is included' do
          expect(application_class).to receive(:create)
            .with(
              remote: remote, account_id: account_id, plan_id: 'planId',
              app_attrs: hash_including('application_key' => 'appKey')
            )
            .and_return(application)
          expect { subject.run }.to output(/Applied application id: 1/).to_stdout
        end
      end
    end
  end
end
