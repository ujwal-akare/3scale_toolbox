RSpec.describe ThreeScaleToolbox::Entities::ActiveDocs do
  include_context :random_name
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }

  context "ActiveDocs.create" do
    let(:activedocs_name) { "adoc_#{random_lowercase_name}" }

    context 'on remote error' do
      let(:remote_response) { { 'errors' => true } }
      let(:activedocs_attrs) { { "name" => activedocs_name } }

      it 'throws an error' do
        expect(remote).to receive(:create_activedocs).and_return(remote_response)
        expect do
          described_class.create(remote: remote, attrs: activedocs_attrs)
        end.to raise_error(ThreeScaleToolbox::Error, /ActiveDocs has not been created/)
      end
    end

    context 'on success when calling the API' do
      let(:activedocs_id) { "5" }
      let(:activedocs_system_name) { "exampleactivedocssysname" }
      let(:activedocs_description) { "description" }
      let(:activedocs_attrs) { { "name" => activedocs_name, "system_name" => activedocs_system_name, "description" => activedocs_description } }
      let(:activedocs_attrs_res) { activedocs_attrs.merge({ "id" => activedocs_id }) }

      it 'an ActiveDocs instance is returned' do
        expect(remote).to receive(:create_activedocs).with(activedocs_attrs).and_return(activedocs_attrs_res)
        adoc_obj = described_class.create(remote: remote, attrs: activedocs_attrs)
        expect(adoc_obj.id).to eq(activedocs_id)
        expect(adoc_obj.remote).to eq(remote)
        expect(adoc_obj.attrs).to eq(activedocs_attrs_res)
      end
    end
  end

  context "ActiveDocs.find" do
    let(:activedocs_attrs_1) { { "name" => "name1", "system_name" => "name1", "id" => "3" } }
    let(:activedocs_attrs_2) { { "name" => "name2", "system_name" => "name2", "id" => "4" } }

    context "ActiveDocs is found by id" do
      let(:activedocs_ref) { "3" }

      it "an instance is returned" do
        expect(remote).to receive(:list_activedocs).and_return([activedocs_attrs_1, activedocs_attrs_2])
        adoc_obj = described_class.find(remote: remote, ref: activedocs_ref)
        expect(adoc_obj).to_not be_nil
        expect(adoc_obj.remote).to eq(remote)
        expect(adoc_obj.attrs).to eq(activedocs_attrs_1)
      end
    end

    context "ActiveDocs is found by system_name" do
      let(:activedocs_ref) { "name2" }

      it "an instance is returned" do
        expect(remote).to receive(:list_activedocs).and_return([activedocs_attrs_1, activedocs_attrs_2]).twice
        adoc_obj = described_class.find(remote: remote, ref: activedocs_ref)
        expect(adoc_obj).to_not be_nil
        expect(adoc_obj.remote).to eq(remote)
        expect(adoc_obj.attrs).to eq(activedocs_attrs_2)
      end
    end

    context "ActiveDocs is not found" do
      let(:activedocs_ref) { "nonexistingname" }

      it "nil is returned" do
        expect(remote).to receive(:list_activedocs).and_return([activedocs_attrs_1, activedocs_attrs_2]).twice
        adoc_obj = described_class.find(remote: remote, ref: activedocs_ref)
        expect(adoc_obj).to be_nil
      end
    end

    context "ActiveDocs is found by id with priority over system_name" do
      let(:activedocs_ref) { "4" }
      let(:activedocs_attrs_1) { { "name" => "name1", "system_name" => "4", "id" => "3" } }
      let(:activedocs_attrs_2) { { "name" => "name2", "system_name" => "name2", "id" => "4" } }

      it "an instance is returned" do
        expect(remote).to receive(:list_activedocs).and_return([activedocs_attrs_1, activedocs_attrs_2])
        adoc_obj = described_class.find(remote: remote, ref: activedocs_ref)
        expect(adoc_obj).to_not be_nil
        expect(adoc_obj.remote).to eq(remote)
        expect(adoc_obj.attrs).to eq(activedocs_attrs_2)
      end
    end
  end

  context "ActiveDocs.find_by_system_name" do
    context "the specified system_name is found" do
      let(:activedocs_sysname_search) { "name2" }
      let(:activedocs_res_id) { "7" }
      let(:activedocs_attrs_1) { { "name" => "name1", "system_name" => "name1", "id" => "5" } }
      let(:activedocs_attrs_2) { { "name" => activedocs_sysname_search, "system_name" => activedocs_sysname_search, "id" => activedocs_res_id } }

      it "an ActiveDocs instance is returned" do
        expect(remote).to receive(:list_activedocs).and_return([activedocs_attrs_1, activedocs_attrs_2])
        adoc_obj = described_class.find_by_system_name(remote: remote, system_name: activedocs_sysname_search)
        expect(adoc_obj.id).to eq(activedocs_res_id)
        expect(adoc_obj.remote).to eq(remote)
        expect(adoc_obj.attrs).to eq(activedocs_attrs_2)
      end
    end

    context "the specified system_name is not found" do
      let(:activedocs_sysname_search) { "name3" }
      let(:activedocs_attrs_1) { { "name" => "name1", "system_name" => "name1", "id" => "5" } }
      let(:activedocs_attrs_2) { { "name" => "name2", "system_name" => "name2", "id" => "7" } }

      it "nil is returned" do
        expect(remote).to receive(:list_activedocs).and_return([activedocs_attrs_1, activedocs_attrs_2])
        adoc_obj = described_class.find_by_system_name(remote: remote, system_name: activedocs_sysname_search)
        expect(adoc_obj).to be_nil
      end
    end
  end

  context "Instance method" do
    let(:activedocs_id) { "5" }

    subject { described_class.new(id: activedocs_id, remote: remote) }

    context "#attrs" do
      it 'calls list_activedocs method' do
        expect(remote).to receive(:list_activedocs).and_return([{ "id" => activedocs_id }])
        subject.attrs
      end

      context 'API cannot be contacted' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'returns an error' do
          expect(remote).to receive(:list_activedocs).and_return(response_body)
          expect do
            subject.attrs
          end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'ID cannot be found' do
        it 'returns an error' do
          expect(remote).to receive(:list_activedocs).and_return([{ "id" => "6" }, { "id" => "7" }])
          expect do
            subject.attrs
          end.to raise_error(ThreeScaleToolbox::ActiveDocsNotFoundError)
        end
      end
    end

    context "#delete" do
      it 'calls delete_activedocs method' do
        expect(remote).to receive(:delete_activedocs)
        subject.delete
      end
    end

    context '#update' do
      let(:params) { { 'name' => 'new name' } }
      let(:id) { "5" }
      let(:new_params) { { 'id' => id, 'name' => 'new_name' } }

      before :example do
        expect(remote).to receive(:update_activedocs).with(id, params).and_return(new_params)
      end

      it 'calls update_service method' do
        expect(subject.update(params)).to eq(new_params)
      end

      it 'call to attrs returns new params' do
        subject.update(params)
        expect(subject.attrs).to eq(new_params)
      end
    end
  end
end
