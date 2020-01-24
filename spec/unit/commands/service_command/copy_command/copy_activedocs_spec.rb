RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyActiveDocsTask do
  context '#call' do
    let(:source_service_id) { 10 }
    let(:target_service_id) { 20 }
    let(:source) { instance_double(ThreeScaleToolbox::Entities::Service, 'source') }
    let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target') }
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:activedocs_class) { class_double(ThreeScaleToolbox::Entities::ActiveDocs).as_stubbed_const }
    let(:activedocs0) do
      {
        'id' => 0, 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => source_service_id
      }
    end
    let(:activedocs) { [activedocs0] }

    subject { described_class.new(source: source, target: target) }

    before :example do
      expect(source).to receive(:activedocs).and_return(activedocs)
      allow(target).to receive(:remote).and_return(remote)
      allow(target).to receive(:id).and_return(target_service_id)
      expect(activedocs_class).to receive(:find_by_system_name).with(remote: remote,
                                                                     system_name: 'ad_0')
                                                               .and_return(target_activedoc)
    end

    context 'target activedocs not found' do
      let(:target_activedoc) { nil }
      let(:expected_create_attrs) do
        { 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => target_service_id }
      end

      it 'activedocs created' do
        expect(activedocs_class).to receive(:create).with(remote: remote,
                                                          attrs: expected_create_attrs)
                                                    .and_return(activedocs)
        subject.call
      end
    end

    context 'target activedocs found' do
      let(:target_activedoc) do
        instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'target_activedocs')
      end

      let(:target_attrs) do
        { 'name' => 'target_ad_0', 'system_name' => 'ad_0', 'service_id' => target_ad_service_id }
      end

      before :example do
        expect(target_activedoc).to receive(:attrs).and_return(target_attrs)
      end

      context 'activedocs owned by target service' do
        let(:target_ad_service_id) { target_service_id }

        let(:expected_update_attrs) do
          { 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => target_service_id }
        end

        it 'activedocs updated' do
          expect(target_activedoc).to receive(:update).with(expected_update_attrs)
          subject.call
        end
      end

      context 'activedocs not owned by target service' do
        let(:target_ad_service_id) { target_service_id + 10 }

        let(:expected_create_attrs) do
          { 'name' => 'ad_0', 'system_name' => "ad_0#{target_service_id}", 'service_id' => target_service_id }
        end

        it 'activedocs created' do
          expect(activedocs_class).to receive(:create).with(remote: remote,
                                                            attrs: expected_create_attrs)
                                                      .and_return(activedocs)
          subject.call
        end
      end
    end
  end
end
