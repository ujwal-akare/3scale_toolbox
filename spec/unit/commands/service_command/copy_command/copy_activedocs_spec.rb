RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyActiveDocsTask do
  context '#call' do
    let(:source_service_id) { 10 }
    let(:target_service_id) { 20 }
    let(:source) { instance_double(ThreeScaleToolbox::Entities::Service, 'source') }
    let(:target) { instance_double(ThreeScaleToolbox::Entities::Service, 'target') }
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:activedocs_class) { class_double(ThreeScaleToolbox::Entities::ActiveDocs).as_stubbed_const }
    let(:activedocs0) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'activedocs0') }
    let(:activedocs0_attrs) do
      {
        'id' => 1, 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => source_service_id
      }
    end
    let(:target_ad_service_id) { target_service_id }
    let(:tgt_activedocs) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'tgt_activedocs') }
    let(:tgt_activedocs_attrs) do
      activedocs0_attrs.merge('id' => 2, 'service_id' => target_ad_service_id)
    end
    let(:activedocs) { [activedocs0] }
    let(:task_context) { { source: source, target: target, logger: Logger.new('/dev/null') } }

    subject { described_class.new(task_context) }

    before :example do
      expect(source).to receive(:activedocs).and_return(activedocs)
      allow(target).to receive(:remote).and_return(remote)
      allow(target).to receive(:id).and_return(target_service_id)
      allow(activedocs0).to receive(:system_name).and_return(activedocs0_attrs.fetch('system_name'))
      allow(activedocs0).to receive(:attrs).and_return(activedocs0_attrs)
      allow(activedocs0).to receive(:id).and_return(1)
      allow(tgt_activedocs).to receive(:system_name).and_return(tgt_activedocs_attrs.fetch('system_name'))
      allow(tgt_activedocs).to receive(:attrs).and_return(tgt_activedocs_attrs)
      allow(tgt_activedocs).to receive(:id).and_return(2)
    end

    context 'target activedocs not found' do
      let(:expected_create_attrs) do
        { 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => target_service_id }
      end

      before :example do
        expect(activedocs_class).to receive(:find_by_system_name).with(remote: remote, system_name: 'ad_0')
          .and_return(nil)
      end

      it 'activedocs created' do
        expect(activedocs_class).to receive(:create).with(remote: remote,
                                                          attrs: expected_create_attrs)
                                                    .and_return(tgt_activedocs)
        subject.call
      end
    end

    context 'target activedocs found' do

      before :example do
        expect(activedocs_class).to receive(:find_by_system_name).with(remote: remote, system_name: 'ad_0')
          .and_return(tgt_activedocs)
      end

      context 'activedocs owned by target service' do

        let(:expected_update_attrs) do
          { 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => target_service_id }
        end

        it 'activedocs updated' do
          expect(tgt_activedocs).to receive(:update).with(expected_update_attrs)

          subject.call
        end
      end

      context 'activedocs not owned by target service' do
        let(:new_tgt_activedocs) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'new_tgt_activedocs') }
        let(:target_ad_service_id) { target_service_id + 10 }

        let(:expected_create_attrs) do
          { 'name' => 'ad_0', 'system_name' => "ad_0#{target_service_id}", 'service_id' => target_service_id }
        end

        before :example do
          allow(new_tgt_activedocs).to receive(:system_name).and_return(tgt_activedocs_attrs.fetch('system_name'))
          allow(new_tgt_activedocs).to receive(:attrs).and_return(tgt_activedocs_attrs)
          allow(new_tgt_activedocs).to receive(:id).and_return(3)
        end

        it 'activedocs created' do
          expect(activedocs_class).to receive(:create).with(remote: remote,
                                                            attrs: expected_create_attrs)
                                                      .and_return(new_tgt_activedocs)
          subject.call
        end
      end
    end
  end
end
