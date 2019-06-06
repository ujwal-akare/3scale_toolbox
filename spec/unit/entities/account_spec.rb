RSpec.describe ThreeScaleToolbox::Entities::Account do
  let(:account_ref) { 'accId' }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:account) { instance_double(ThreeScaleToolbox::Entities::Account) }
  let(:show_account_error) { { 'errors' => 'some error' } }
  let(:application_class) { class_double(ThreeScaleToolbox::Entities::Application).as_stubbed_const }

  context '#Account.find' do
    context 'show_account returns error' do
      before :example do
        expect(remote).to receive(:show_account).with(account_ref).and_return(show_account_error)
      end

      it 'error is raised' do
        expect do
          described_class.find(remote: remote, ref: account_ref)
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Account attrs not read/)
      end
    end

    context 'show_account raises NotFoundError' do
      before :example do
        expect(remote).to receive(:show_account).with(account_ref)
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError)
      end

      it 'find_by_example is called' do
        expect(described_class).to receive(:find_by_text).with(account_ref, remote)
                                                         .and_return(account)
        expect(described_class.find(remote: remote, ref: account_ref)).to be(account)
      end
    end

    context 'show_account returns account' do
      let(:account_attrs) { { 'id' => account_ref, 'name' => 'some name' } }
      before :example do
        expect(remote).to receive(:show_account).with(account_ref).and_return(account_attrs)
      end

      it 'account instance is returned' do
        result = described_class.find(remote: remote, ref: account_ref)
        expect(result).not_to be_nil
        expect(result.attrs).to eq(account_attrs)
      end
    end
  end

  context '#Account.find_by_text' do
    # TODO
  end

  context '#applications' do
    let(:subject) { described_class.new(id: account_ref, remote: remote) }

    context 'list_account_applications returns error' do
      let(:request_error) { { 'errors' => 'some error' } }

      before :example do
        expect(remote).to receive(:list_account_applications).with(account_ref)
                                                             .and_return(request_error)
      end

      it 'error is raised' do
        expect { subject.applications }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Account applications not read/)
      end
    end

    context 'list_account_applications returns applications' do
      let(:app01_attrs) { { 'id' => '01', 'name' => 'app01' } }
      let(:app02_attrs) { { 'id' => '02', 'name' => 'app02' } }
      let(:app03_attrs) { { 'id' => '03', 'name' => 'app03' } }
      let(:applications) { [app01_attrs, app02_attrs, app03_attrs] }

      before :example do
        expect(remote).to receive(:list_account_applications).with(account_ref)
                                                             .and_return(applications)
      end

      it 'app01 is returned' do
        apps = subject.applications
        expect(apps.map(&:id)).to include('01')
      end

      it 'app02 is returned' do
        apps = subject.applications
        expect(apps.map(&:id)).to include('02')
      end

      it 'app03 is returned' do
        apps = subject.applications
        expect(apps.map(&:id)).to include('03')
      end
    end
  end
end
